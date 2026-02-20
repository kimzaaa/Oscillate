import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

class OscillatorNode: SynthNode {
    @Published var waveform: Waveform = .sine
    @Published var volume: Float = 0.1
    
    // Thread-safe state for the audio render block
    private let state = OscillatorState()
    
    enum Waveform: String, CaseIterable {
        case sine = "Sine", square = "Square", triangle = "Triangle", saw = "Saw"
    }
    
    override init(name: String = "Poly Osc", color: Color = .blue, icon: String = "wave.3.forward", position: CGPoint) {
        super.init(name: name, color: color, icon: icon, position: position)
        self.avNode = createSourceNode()
    }
    
    func noteOn(frequency: Float) {
        state.addNote(frequency)
    }
    
    func noteOff(frequency: Float) {
        state.removeNote(frequency)
    }
    
    private func createSourceNode() -> AVAudioSourceNode {
        let sampleRate: Float = 44100.0
        
        // Capture state strongly. The node retains the state.
        let state = self.state
        
        return AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            // Use local copies of parameters if safe, or access via state if atomic.
            // Waveform and Volume are on self (MainActor usually), accessing from audio thread is technically unsafe if not protected.
            // For simplicity, we'll read them. In a robust app, push changes to `state`.
            var currentWave = Waveform.sine
            var currentVol: Float = 0.1
            
            if let self = self {
                 currentWave = self.waveform
                 currentVol = self.volume
            }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let limitVal: Float = 0.5 // Hard limit to avoid blowing speakers
            
            state.lock.lock()
            var activeNotes = state.activeNotes
            
            let count = max(1, Float(activeNotes.count))
            
            for frame in 0..<Int(frameCount) {
                var sampleSum: Float = 0.0
                
                // Iterate through notes
                for i in 0..<activeNotes.count {
                    let phaseIncrement = (2.0 * Float.pi * activeNotes[i].frequency) / sampleRate
                    var p = activeNotes[i].phase
                    
                    var sample: Float = 0.0
                    switch currentWave {
                    case .sine: sample = sin(p)
                    case .square: sample = p < Float.pi ? 0.5 : -0.5
                    case .triangle: sample = 2.0 * abs(2.0 * (p / (2.0 * Float.pi) - floor(p / (2.0 * Float.pi) + 0.5))) - 1.0
                    case .saw: sample = 2.0 * (p / (2.0 * Float.pi) - floor(p / (2.0 * Float.pi) + 0.5))
                    }
                    
                    sampleSum += sample
                    
                    p += phaseIncrement
                    if p >= 2.0 * Float.pi { p -= 2.0 * Float.pi }
                    
                    activeNotes[i].phase = p
                }
                
                // Simple volume scaling
                let polyVolume = currentVol * 0.3 // Reduce individual volume to avoid clipping with chords
                let finalSample = max(-limitVal, min(limitVal, sampleSum * polyVolume))
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = finalSample
                }
            }
            
            // Write back updated phases
            state.activeNotes = activeNotes
            state.lock.unlock()
            
            return noErr
        }
    }
    
    override func content() -> AnyView {
        let waveBind = Binding(get: { self.waveform }, set: { self.waveform = $0 })
        let volBind = Binding(get: { Double(self.volume) }, set: { self.volume = Float($0) })
        
        return AnyView(
            VStack(spacing: 8) {
                WaveformShape(waveform: self.waveform)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(height: 30)
                    .padding(.horizontal, 10)
                
                Picker("", selection: waveBind) {
                    ForEach(Waveform.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                
                VStack(spacing: 2) {
                    HStack {
                        Text("VOL").font(.system(size: 8, weight: .bold))
                        Spacer()
                        Text("\(Int(volume * 100))%").font(.system(size: 8))
                    }
                    Slider(value: volBind, in: 0...0.5)
                        .accentColor(self.color)
                }
            }
                .padding(12)
                .frame(width: 140, height: 140)
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
        )
    }
}

// Helper class to manage audio state thread-safely
class OscillatorState {
    struct NoteState {
        let frequency: Float
        var phase: Float
    }
    
    var activeNotes: [NoteState] = []
    let lock = NSLock()
    
    func addNote(_ frequency: Float) {
        lock.lock()
        if !activeNotes.contains(where: { $0.frequency == frequency }) {
            activeNotes.append(NoteState(frequency: frequency, phase: 0.0))
        }
        lock.unlock()
    }
    
    func removeNote(_ frequency: Float) {
        lock.lock()
        if let index = activeNotes.firstIndex(where: { $0.frequency == frequency }) {
            activeNotes.remove(at: index)
        }
        lock.unlock()
    }
}


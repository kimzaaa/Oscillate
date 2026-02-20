import SwiftUI
import AVFoundation

class ADSRNode: SynthNode {
    @Published var attack: Float = 0.05
    @Published var decay: Float = 0.05
    @Published var sustain: Float = 0.5
    @Published var release: Float = 0.1
    
    private let mixer = AVAudioMixerNode()
    private var timer: Timer?
    
    init(position: CGPoint) {
        super.init(name: "ADSR", color: .green, icon: "waveform.path", position: position)
        self.avNode = mixer
        startEnvelopeTimer()
    }
    
    private func startEnvelopeTimer() {
        // --- FASTER TIMING ---
        let totalCycle: TimeInterval = 1  // Total loop length (very fast)
        let noteOffTime: TimeInterval = 0.2 // Key release happens almost immediately
        var currentTime: TimeInterval = 0
        let updateInterval: TimeInterval = 1.0 / 120.0 // Higher resolution for fast beats
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let t = currentTime.truncatingRemainder(dividingBy: totalCycle)
            var volume: Float = 0.0
            
            let a = Double(self.attack)
            let d = Double(self.decay)
            let s = Double(self.sustain)
            let r = Double(self.release)
            
            if t < a {
                volume = Float(t / a)
            } else if t < (a + d) {
                let dProgress = (t - a) / d
                volume = Float(1.0 - (dProgress * (1.0 - s)))
            } else if t < noteOffTime {
                volume = Float(s)
            } else if t < (noteOffTime + r) {
                let rProgress = (t - noteOffTime) / r
                volume = Float(s * (1.0 - rProgress))
            } else {
                volume = 0.0
            }
            
            self.mixer.outputVolume = max(0, volume)
            currentTime += updateInterval
        }
    }
    
    override func content() -> AnyView {
        // Explicit bindings for reliability
        let a = Binding(get: { self.attack }, set: { self.attack = $0 })
        let d = Binding(get: { self.decay }, set: { self.decay = $0 })
        let s = Binding(get: { self.sustain }, set: { self.sustain = $0 })
        let r = Binding(get: { self.release }, set: { self.release = $0 })
        
        return AnyView(
            VStack(spacing: 12) {
                envelopeSlider(label: "A", value: a, range: 0.001...0.2)
                envelopeSlider(label: "D", value: d, range: 0.001...0.2)
                envelopeSlider(label: "S", value: s, range: 0.0...1.0)
                envelopeSlider(label: "R", value: r, range: 0.001...0.4)
            }
                .padding(12)
                .background(Color.green) // Background to make black text pop
                .cornerRadius(8)
                .frame(width: 220)
        )
    }
    
    private func envelopeSlider(label: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .bold()
                .foregroundColor(.black) // Text changed to Black
                .frame(width: 15)
            
            Slider(value: value, in: range)
                .accentColor(.black) // Slider track changed to Black
            
            Text(String(format: "%.2f", value.wrappedValue))
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.black) // Value label changed to Black
                .frame(width: 35, alignment: .trailing)
        }
    }
}


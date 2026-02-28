import SwiftUI
import AVFoundation

class ADSRNode: SynthNode {
    @Published var attack: Float = 0.1
    @Published var decay: Float = 0.1
    @Published var sustain: Float = 0.5
    @Published var release: Float = 0.5
    
    private let mixer = AVAudioMixerNode()
    private var timer: Timer?
    
    private enum EnvelopeState {
        case idle, attack, decay, sustain, release
    }
    
    private var state: EnvelopeState = .idle
    private var stateStartTime: TimeInterval = 0
    private var releaseStartVolume: Float = 0
    
    private var activeKeys = 0
    
    init(position: CGPoint) {
        super.init(name: "ADSR", color: .green, icon: "waveform.path", position: position)
        self.avNode = mixer
        
        self.mixer.outputVolume = 0
        
        startEnvelopeTimer()
    }
    
    func noteOn() {
        activeKeys += 1
        
        if activeKeys == 1 {
            triggerAttack()
        }
    }
    
    func noteOff() {
        activeKeys = max(0, activeKeys - 1)
        
        if activeKeys == 0 {
            triggerRelease()
        }
    }
    
    private func triggerAttack() {
        state = .attack
        stateStartTime = Date().timeIntervalSince1970
    }
    
    private func triggerRelease() {
        if state != .idle {
            
            releaseStartVolume = mixer.outputVolume
            state = .release
            stateStartTime = Date().timeIntervalSince1970
        }
    }
    
    private func startEnvelopeTimer() {
        
        let updateInterval: TimeInterval = 1.0 / 60.0
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateEnvelope()
        }
    }
    
    private func updateEnvelope() {
        let now = Date().timeIntervalSince1970
        let t = Float(now - stateStartTime)
        var currentVolume: Float = 0.0
        
        let a = max(0.01, attack)
        let d = max(0.01, decay)
        let s = max(0.0, min(1.0, sustain))
        let r = max(0.01, release)
        
        switch state {
        case .idle:
            currentVolume = 0.0
            
        case .attack:
            if t < a {
                currentVolume = t / a
            } else {
                
                currentVolume = 1.0
                state = .decay
                stateStartTime = now
            }
            
        case .decay:
            if t < d {
                let progress = t / d
                
                currentVolume = 1.0 - (progress * (1.0 - s))
            } else {
                
                currentVolume = s
                state = .sustain
                
            }
            
        case .sustain:
            currentVolume = s
            
        case .release:
            if t < r {
                let progress = t / r
                
                currentVolume = releaseStartVolume * (1.0 - progress)
            } else {
                
                currentVolume = 0.0
                state = .idle
            }
        }
        
        mixer.outputVolume = max(0.0, min(1.0, currentVolume))
    }
    
    override func content() -> AnyView {
        
        let a = Binding(get: { self.attack }, set: { self.attack = $0 })
        let d = Binding(get: { self.decay }, set: { self.decay = $0 })
        let s = Binding(get: { self.sustain }, set: { self.sustain = $0 })
        let r = Binding(get: { self.release }, set: { self.release = $0 })
        
        return AnyView(
            VStack(spacing: 12) {
                envelopeSlider(label: "A", value: a, range: 0.01...2.0)
                envelopeSlider(label: "D", value: d, range: 0.01...2.0)
                envelopeSlider(label: "S", value: s, range: 0.0...1.0)
                envelopeSlider(label: "R", value: r, range: 0.01...3.0)
            }
                .padding(12)
                .background(Color.green)
                .cornerRadius(8)
                .frame(width: 220)
        )
    }
    
    private func envelopeSlider(label: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .bold()
                .foregroundColor(.black)
                .frame(width: 15)
            
            Slider(value: value, in: range)
                .accentColor(.black)
            
            Text(String(format: "%.2f", value.wrappedValue))
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

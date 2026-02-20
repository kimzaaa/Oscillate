import AVFoundation

class AudioEngine {
    static let shared = AudioEngine()
    let engine = AVAudioEngine()
    let mainMixer: AVAudioMixerNode
    
    private init() {
        mainMixer = engine.mainMixerNode
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        try? engine.start()
    }
}

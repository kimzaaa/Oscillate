import SwiftUI
import AVFoundation

class OutputNode: SynthNode {
    
    override init(name: String = "Output", color: Color = .red, icon: String = "speaker.wave.3.fill", position: CGPoint) {
        super.init(name: name, color: color, icon: icon, position: position)
        self.avNode = AudioEngine.shared.mainMixer
        
        AudioEngine.shared.mainMixer.outputVolume = 1.0
    }
    
    override func content() -> AnyView {
        
        return AnyView(
            Image(systemName: "speaker.wave.3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        )
    }
}

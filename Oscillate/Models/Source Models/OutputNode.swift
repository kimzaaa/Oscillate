import SwiftUI
import AVFoundation

class OutputNode: SynthNode {
    
    override init(name: String = "Output", color: Color = .red, icon: String = "speaker.wave.3.fill", position: CGPoint) {
        super.init(name: name, color: color, icon: icon, position: position)
        self.avNode = AudioEngine.shared.mainMixer
        
        // Ensure volume is on by default so keyboard triggers sound
        AudioEngine.shared.mainMixer.outputVolume = 1.0
    }
    
    override func content() -> AnyView {
        // Just show the icon, no button interaction
        return AnyView(
            Image(systemName: "speaker.wave.3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        )
    }
}
// Removed OutputButton struct as it's no longer needed for interaction

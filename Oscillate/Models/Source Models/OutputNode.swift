import SwiftUI
import AVFoundation

class OutputNode: SynthNode {
    
    override init(name: String = "Output", color: Color = .red, icon: String = "speaker.wave.3.fill", position: CGPoint) {
        super.init(name: name, color: color, icon: icon, position: position)
        self.avNode = AudioEngine.shared.mainMixer
        
        // Start muted!
        AudioEngine.shared.mainMixer.outputVolume = 0
    }
    
    override func content() -> AnyView {
        return AnyView(
            OutputButton()
        )
    }
}

struct OutputButton: View {
    @State private var isPressed = false
    
    var body: some View {
        Image(systemName: isPressed ? "speaker.wave.3.fill" : "speaker.slash.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .animation(.spring(), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            AudioEngine.shared.mainMixer.outputVolume = 1.0
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        AudioEngine.shared.mainMixer.outputVolume = 0.0
                    }
            )
    }
}

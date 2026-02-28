import SwiftUI

struct SandboxMain: View {
    @State private var navigateToMain = false
    
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true,
        midiFilename: "RESONANCE",
        midiPlaybackSpeed: 1,
        availableNodes: ["Oscillator", "ADSR", "Reverb", "Resonance", "Filter", "Pitch"],
        initialNodes: [],
        hintText: nil,
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [],
        requiredSettings: [],
        successMessage: nil,
        nextLevelViewName: nil,
        requireNoteInput: false
    )
    
    var body: some View {
        if navigateToMain {
            Main()
        } else {
            SynthLevelView(config: config)
                .navigationBarBackButtonHidden(true)
                .overlay(alignment: .topLeading) {
                    Button(action: {
                        navigateToMain = true
                    }) {
                        Text("<")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            .padding(.top, 10)
                    }
                }
        }
    }
}

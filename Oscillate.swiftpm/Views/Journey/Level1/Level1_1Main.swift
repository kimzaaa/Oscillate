import SwiftUI

struct Level1_1Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine")
        ],
        hintText: "The sound only generates if there is an Oscillator node in the chain, and is connected to the output node.",
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Sound confirmed. Navigation unlocked.",
        nextLevelViewName: "Level1_2", 
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

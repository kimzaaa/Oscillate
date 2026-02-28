import SwiftUI

struct Level1_1Main: View {
    // Level 1-1 configuration
    // Example: Maybe now they need to change the waveform
    let config = LevelConfiguration(
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
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Sound confirmed. Navigation unlocked.",
        nextLevelViewName: "Level1_2", // Assuming new level
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}


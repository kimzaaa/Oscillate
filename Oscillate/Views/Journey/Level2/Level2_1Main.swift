import SwiftUI

struct Level2_1Main: View {
    // Level 1-1 configuration
    // Example: Maybe now they need to change the waveform
    let config = LevelConfiguration(
        showKeyboard: false,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "ADSR", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("ADSR", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "A sound can shape with a help of other modules in one track",
        playDialogueOnStart: "lv2d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200129/ScreenRecording_02-27-2569_20-39-41_1_gzqx0d.mp4",
        videoSize: CGSize(width: 1200, height: 500),
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Now try adjusting the sliders",
        nextLevelViewName: "Level2_2", // Assuming new level
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}


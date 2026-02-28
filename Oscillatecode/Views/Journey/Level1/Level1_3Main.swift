import SwiftUI

struct Level1_3Main: View {
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 50), "Sine"),
            ("Oscillator", CGPoint(x: 200, y: 300), "Triangle")
        ],
        hintText: "You can move around by dragging the screen at an empty space, or zoom with a pinch. You can also add more nodes by tapping your desired node in the Library menu",
        playDialogueOnStart: "lv1d3",
        playVideoOnStart: "Lv1-3",
        videoSize: CGSize(width: 1200, height: 500),
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [
        ],
        successMessage: "Level 1 Complete, Your Journey Begins",
        nextLevelViewName: "Level2",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

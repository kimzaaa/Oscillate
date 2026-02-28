import SwiftUI

struct Level1_2Main: View {
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine")
        ],
        hintText: "You can move the node's position, by holding anywhere within the node's boundaries and drag it across.",
        playDialogueOnStart: "lv1d2",
        playVideoOnStart: "Lv1-2",
        videoSize: CGSize(width: 1200, height: 500),
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [
            LevelConfig.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: 1.0),
        ],
        successMessage: "Great job!",
        nextLevelViewName: "Level1_3",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

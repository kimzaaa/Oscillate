import SwiftUI

struct Level3_2Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: true, 
        midiFilename: "lv3", 
        midiPlaybackSpeed: 0.7, 
        availableNodes: ["Oscillator", "Output", "Pitch"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Saw"),
            ("Pitch", CGPoint(x: 500, y: 300), nil),
            ("Oscillator", CGPoint(x: 200, y: 0), "Saw"),
            ("Pitch", CGPoint(x: 500, y: 0), nil),
            ("Oscillator", CGPoint(x: 200, y: 600), "Saw"),
            ("Pitch", CGPoint(x: 500, y: 600), nil)
        ],
        hintText: "Remember, one effects node, can only be connected by one Oscillator node, or a chain concluding to it",
        playDialogueOnStart: nil,
        playVideoOnStart: nil, 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Output"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Output"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Output")
        ],
        requiredSettings: [
            LevelConfig.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 50, tolerance: 49.0),
            LevelConfig.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: -50.0, tolerance: 49.0)
        ],
        successMessage: "You've just made a Unison effect!. It is very common in modern electronic musics!",
        nextLevelViewName: "Level4_1",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

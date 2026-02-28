import SwiftUI

struct Level4_2Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: true, 
        midiFilename: "lv4", 
        midiPlaybackSpeed: 0.9, 
        availableNodes: ["Oscillator", "Output", "Filter"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Saw"),
            ("Filter", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Try toggling the Automation button and set its speed level VERY high",
        playDialogueOnStart: "lv4d2",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772204610/ScreenRecording_02-27-2569_22-01-16_1_eds7o6.mp4", 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Filter"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output")
        ],
        requiredSettings: [
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3)
        ],
        successMessage: "Nice! Now let's do something more fun!!",
        nextLevelViewName: "Level5_1",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

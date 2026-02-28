import SwiftUI

struct Level5_3Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: true, 
        midiFilename: "RESONANCE", 
        midiPlaybackSpeed: 1, 
        availableNodes: ["Oscillator", "Output", "ADSR" ,"Pitch","Filter"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: -400, y: -200), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: -200), nil),
            ("Filter", CGPoint(x: 500, y: -200), nil),
            ("Oscillator", CGPoint(x: -400, y: 100), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 100), nil),
            ("Pitch", CGPoint(x: 200, y: 100), nil),
            ("Filter", CGPoint(x: 500, y: 100), nil),
            ("Oscillator", CGPoint(x: -400, y: 400), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 400), nil),
            ("Pitch", CGPoint(x: 200, y: 400), nil),
            ("Filter", CGPoint(x: 500, y: 400), nil),
            ("Oscillator", CGPoint(x: -400, y: 700), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 700), nil),
            ("Pitch", CGPoint(x: 200, y: 700), nil),
            ("Filter", CGPoint(x: 500, y: 700), nil),
        ],
        hintText: "Turn on Filter automation, set the speed high, and pitch each node a little.",
        playDialogueOnStart: nil,
        playVideoOnStart: nil, 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output"),
        ],
        requiredSettings: [
            LevelConfig.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            
            LevelConfig.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 20, tolerance: 19),
            LevelConfig.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 0, tolerance: 100),
            LevelConfig.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: -20, tolerance: 19),
            
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfig.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
        ],
        successMessage: "You've made the popular synth from the song : Resonance by home! I think it's time for you to create your own journey",
        nextLevelViewName: "Sandbox",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

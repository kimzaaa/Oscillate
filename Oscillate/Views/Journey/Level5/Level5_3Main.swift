import SwiftUI

struct Level5_3Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true, // Example: Enable MIDI with a hardcoded file
        midiFilename: "RESONANCE", // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: 1, // Fixed speed
        availableNodes: ["Oscillator", "Output", "ADSR" ,"Pitch","Filter"], // Limited toolset
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
        playVideoOnStart: nil, // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output"),
            
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Filter"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output"),
        ],
        requiredSettings: [
            LevelConfiguration.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil),
            
            LevelConfiguration.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 20, tolerance: 19),
            LevelConfiguration.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 0, tolerance: 100),
            LevelConfiguration.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: -20, tolerance: 19),
            
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3),
        ],
        successMessage: "You've made the popular synth from the song : Resonance by home! I think it's time for you to create your own journey",
        nextLevelViewName: "Sandbox",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}
// 4-1 user learn what each thing does [/]
// 4-2 user learn automation [/]
// lv 5-1 4 osc 4 adsr connect [/]
// 5-2 4 osc 4 adsr 3 pitch connect [/]
// 5-3 all + tweak [/]
// -> sandbox / sound library (?)

import SwiftUI

struct Level4_2Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true, // Example: Enable MIDI with a hardcoded file
        midiFilename: "lv4", // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: 0.9, // Fixed speed
        availableNodes: ["Oscillator", "Output", "Filter"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Saw"),
            ("Filter", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Try toggling the Automation button and set its speed level VERY high",
        playDialogueOnStart: "lv4d2",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772204610/ScreenRecording_02-27-2569_22-01-16_1_eds7o6.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Filter"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output")
        ],
        requiredSettings: [
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "isAuto", targetValue: 1.0, tolerance: nil),
            LevelConfiguration.SettingGoal(nodeType: "Filter", settingName: "autoSpeed", targetValue: 0.9, tolerance: 0.3)
        ],
        successMessage: "Nice! Now let's do something more fun!!",
        nextLevelViewName: "Level5_1",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}
// 4-1 user learn what each thing does [/]
// 4-2 user learn automation [/]
// lv 5-1 4 osc 4 adsr connect
// 5-2 4 osc 4 adsr 3 pitch connect
// 5-3 all + tweak
// -> sandbox / sound library (?)





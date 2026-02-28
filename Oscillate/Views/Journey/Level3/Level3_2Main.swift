import SwiftUI

struct Level3_2Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true, // Example: Enable MIDI with a hardcoded file
        midiFilename: "lv3", // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: 0.7, // Fixed speed
        availableNodes: ["Oscillator", "Output", "Pitch"], // Limited toolset
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
        playVideoOnStart: nil, // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Output"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Output"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Output")
        ],
        requiredSettings: [
            LevelConfiguration.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: 50, tolerance: 49.0),
            LevelConfiguration.SettingGoal(nodeType: "Pitch", settingName: "pitch", targetValue: -50.0, tolerance: 49.0)
        ],
        successMessage: "You've just made a Unison effect!. It is very common in modern electronic musics!",
        nextLevelViewName: "Level4_1",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}





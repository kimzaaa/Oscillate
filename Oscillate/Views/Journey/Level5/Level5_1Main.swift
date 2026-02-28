import SwiftUI

struct Level5_1Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: false,
        showMidi: false, // Example: Enable MIDI with a hardcoded file
        midiFilename: nil, // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: nil, // Fixed speed
        availableNodes: ["Oscillator", "Output", "ADSR"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: -400, y: -200), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: -200), nil),
            ("Oscillator", CGPoint(x: -400, y: 100), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 100), nil),
            ("Oscillator", CGPoint(x: -400, y: 400), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 400), nil),
            ("Oscillator", CGPoint(x: -400, y: 700), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 700), nil),
        ],
        hintText: "Connect everything where one Oscillator node can only connect with one effect nodes at a time.",
        playDialogueOnStart: "lv5d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200131/ScreenRecording_02-27-2569_20-44-13_1_gpauqt.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),   
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            
        ],
        requiredSettings: [
            
        ],
        successMessage: "Just trust the process!",
        nextLevelViewName: "Level5_2",
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}
// 4-1 user learn what each thing does [/]
// 4-2 user learn automation [/]
// lv 5-1 4 osc 4 adsr connect [/]
// 5-2 4 osc 4 adsr 3 pitch connect
// 5-3 all + tweak
// -> sandbox / sound library (?)





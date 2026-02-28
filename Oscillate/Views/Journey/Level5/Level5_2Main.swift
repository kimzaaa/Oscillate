import SwiftUI

struct Level5_2Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: false,
        showMidi: false, // Example: Enable MIDI with a hardcoded file
        midiFilename: nil, // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: nil, // Fixed speed
        availableNodes: ["Oscillator", "Output", "ADSR" ,"Pitch"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: -400, y: -200), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: -200), nil),
            ("Oscillator", CGPoint(x: -400, y: 100), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 100), nil),
            ("Pitch", CGPoint(x: 200, y: 100), nil),
            ("Oscillator", CGPoint(x: -400, y: 400), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 400), nil),
            ("Pitch", CGPoint(x: 200, y: 400), nil),
            ("Oscillator", CGPoint(x: -400, y: 700), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 700), nil),
            ("Pitch", CGPoint(x: 200, y: 700), nil),
        ],
        hintText: "Connect everything where one Oscillator node can only connect with one effect nodes at a time.",
        playDialogueOnStart: nil,
        playVideoOnStart: nil, // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
        ],
        requiredSettings: [
            
        ],
        successMessage: "One last step!!",
        nextLevelViewName: "Level5_3",
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}
// 4-1 user learn what each thing does [/]
// 4-2 user learn automation [/]
// lv 5-1 4 osc 4 adsr connect [/]
// 5-2 4 osc 4 adsr 3 pitch connect [/]
// 5-3 all + tweak
// -> sandbox / sound library (?)





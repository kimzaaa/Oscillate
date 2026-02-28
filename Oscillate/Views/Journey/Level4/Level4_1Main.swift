import SwiftUI

struct Level4_1Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: false, // Example: Enable MIDI with a hardcoded file
        midiFilename: nil, // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: nil, // Fixed speed
        availableNodes: ["Oscillator", "Output", "Filter"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Triangle"),
            ("Filter", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Highpass (HP): Blocks bass, lets treble through. \nLowpass (LP): Blocks treble, lets bass through. \nBandpass (BP): Only lets middle frequencies through.",
        playDialogueOnStart: "lv4d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200129/ScreenRecording_02-27-2569_20-41-44_1_asy9wm.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Filter"),
            LevelConfiguration.ConnectionGoal(fromType: "Filter", toType: "Output")
        ],
        requiredSettings: [
            
        ],
        successMessage: "Nice! Now let's do something more fun!!",
        nextLevelViewName: "Level4_2",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}
// 4-1 user learn what each thing does [/]
// 4-2 user learn automation
// lv 5-1 4 osc 4 adsr connect
// 5-2 4 osc 4 adsr 3 pitch connect
// 5-3 all + tweak
// -> sandbox / sound library (?)





import SwiftUI

struct Level1Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true, // Example: Enable MIDI with a hardcoded file
        midiFilename: "level1_melody", // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: 1.0, // Fixed speed
        availableNodes: ["Oscillator", "Output"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), nil)
        ],
        hintText: "Connect the Oscillator to the Output using a wire. Tap the output node to hear sound.",
        playDialogueOnStart: "lv1d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1771895970/lv1m1_bho1oa.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 400, height: 200),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "You should try playing a sound with a keyboard.",
        nextLevelViewName: "Level1_1",
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

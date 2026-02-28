import SwiftUI

struct Level1Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: false,
        showMidi: false, // Example: Enable MIDI with a hardcoded file
        midiFilename: "level1_melody", // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: 1.0, // Fixed speed
        availableNodes: ["Oscillator", "Output"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine")
        ],
        hintText: "Hold the green orb next to the node, and drag it to the yellow output node",
        playDialogueOnStart: "lv1d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772021321/ScreenRecording_02-25-2569_19-04-53_1_i1foav.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
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


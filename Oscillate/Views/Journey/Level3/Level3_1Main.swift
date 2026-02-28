import SwiftUI

struct Level3_1Main: View {
    // Level 1 specific configuration
    // Example: Only Oscillators and Output allowed, maybe a tutorial MIDI playing?
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: false, // Example: Enable MIDI with a hardcoded file
        midiFilename: nil, // Example filename, assumes it exists in bundle
        midiPlaybackSpeed: nil, // Fixed speed
        availableNodes: ["Oscillator", "Output", "Pitch"], // Limited toolset
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("Pitch", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Try Adjusting the sliders",
        playDialogueOnStart: "lv3d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200126/ScreenRecording_02-27-2569_20-40-57_1_urx6xe.mp4", // Add your MP4 file with this name to Resources
        videoSize: CGSize(width: 1200, height: 500),
        
        // Goals
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfiguration.ConnectionGoal(fromType: "Pitch", toType: "Output")
        ],
        requiredSettings: [
            
        ],
        successMessage: "You can see the notes shifting. Now let's do something fun",
        nextLevelViewName: "Level3_2",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}




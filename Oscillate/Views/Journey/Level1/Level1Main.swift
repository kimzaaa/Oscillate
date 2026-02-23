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
            ("Oscillator", CGPoint(x: 200, y: 300))
        ],
        hintText: "Connect the Oscillator to the Output using a wire. Tap the output node to hear sound.",
        playDialogueOnStart: "lv1d1"
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

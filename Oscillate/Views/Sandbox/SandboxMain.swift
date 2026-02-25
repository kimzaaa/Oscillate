import SwiftUI

struct SandboxMain: View {
    // Sandbox has everything enabled
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true, // Show MIDI controls with file picker
        midiFilename: nil, // Allow user to pick file
        midiPlaybackSpeed: nil, // Allow user to change speed with slider
        availableNodes: ["Oscillator", "ADSR", "Reverb", "Resonance", "Filter", "Pitch"],
        initialNodes: [],
        hintText: nil,
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [],
        requiredSettings: [],
        successMessage: nil,
        nextLevelViewName: nil,
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}


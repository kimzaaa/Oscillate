//
//  Level1_1Main.swift
//  Oscillate
//
//  Created by Copilot on 2/24/2026.
//

import SwiftUI

struct Level1_1Main: View {
    // Level 1-1 configuration
    // Example: Maybe now they need to change the waveform
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine")
        ],
        hintText: "Connect OSC -> OUT, then play a key. Tap 'Play Audio' for voice hint.",
        hintAudioFilename: "level1_1_hint", // nil = no audio button in hint popup
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "Output")
        ],
        requiredSettings: [
            // 0=sine, 1=square, 2=triangle, 3=saw
            LevelConfiguration.SettingGoal(nodeType: "Oscillator", settingName: "waveform", targetValue: 2.0, tolerance: nil)
        ],
        successMessage: "Sound confirmed. Navigation unlocked.",
        nextLevelViewName: "Level1_2", // Assuming new level
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

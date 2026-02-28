import SwiftUI

struct Level2_3Main: View {
    // Level 1-1 configuration
    // Example: Maybe now they need to change the waveform
    let config = LevelConfiguration(
        showKeyboard: true,
        showMidi: true,
        midiFilename: "lv2",
        midiPlaybackSpeed: 0.7,
        availableNodes: ["Oscillator", "ADSR", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("ADSR", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Set attack and sustain to VERY VERY low",
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [
            LevelConfiguration.SettingGoal(nodeType: "ADSR", settingName: "attack", targetValue: 0.0, tolerance: 0.2),
            LevelConfiguration.SettingGoal(nodeType: "ADSR", settingName: "sustain", targetValue: 0.0, tolerance: 0.2)
        ],
        successMessage: "Good job!",
        nextLevelViewName: "Level3_1", // Assuming new level
        requireNoteInput: true
    )
    
    
    var body: some View {
        ZStack {
            // 2. The Base Game Layer
            SynthLevelView(config: config)
            
            // 3. The Visualizer Overlay (Only for this level)
            VStack {
                HStack {
                    // Place it Top-Left
                    AudioVisualizer()
                        .frame(width: 300, height: 150)
                        .padding([.top, .leading], 20)
                        .shadow(radius: 10)
                    
                    Spacer()
                }
                Spacer()
            }
            // Ensure it doesn't catch touches meant for the game below
            .allowsHitTesting(false) 
        }
    }
}




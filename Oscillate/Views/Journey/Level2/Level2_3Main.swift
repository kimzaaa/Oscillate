import SwiftUI

struct Level2_3Main: View {
    
    let config = LevelConfig(
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
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [
            LevelConfig.SettingGoal(nodeType: "ADSR", settingName: "attack", targetValue: 0.0, tolerance: 0.2),
            LevelConfig.SettingGoal(nodeType: "ADSR", settingName: "sustain", targetValue: 0.0, tolerance: 0.2)
        ],
        successMessage: "Good job!",
        nextLevelViewName: "Level3_1", 
        requireNoteInput: true
    )
    
    var body: some View {
        ZStack {
            
            SynthLevelView(config: config)
            
            VStack {
                HStack {
                    
                    AudioVisualizer()
                        .frame(width: 300, height: 150)
                        .padding([.top, .leading], 20)
                        .shadow(radius: 10)
                    
                    Spacer()
                }
                Spacer()
            }
            
            .allowsHitTesting(false) 
        }
    }
}

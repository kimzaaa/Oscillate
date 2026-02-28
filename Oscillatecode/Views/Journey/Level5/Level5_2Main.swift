import SwiftUI

struct Level5_2Main: View {
    
    let config = LevelConfig(
        showKeyboard: false,
        showMidi: false, 
        midiFilename: nil, 
        midiPlaybackSpeed: nil, 
        availableNodes: ["Oscillator", "Output", "ADSR" ,"Pitch"], 
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
        playVideoOnStart: nil, 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Pitch"),
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

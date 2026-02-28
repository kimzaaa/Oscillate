import SwiftUI

struct Level5_1Main: View {
    
    let config = LevelConfig(
        showKeyboard: false,
        showMidi: false, 
        midiFilename: nil, 
        midiPlaybackSpeed: nil, 
        availableNodes: ["Oscillator", "Output", "ADSR"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: -400, y: -200), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: -200), nil),
            ("Oscillator", CGPoint(x: -400, y: 100), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 100), nil),
            ("Oscillator", CGPoint(x: -400, y: 400), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 400), nil),
            ("Oscillator", CGPoint(x: -400, y: 700), "Triangle"),
            ("ADSR", CGPoint(x: -100, y: 700), nil),
        ],
        hintText: "Connect everything where one Oscillator node can only connect with one effect nodes at a time.",
        playDialogueOnStart: "lv5d1",
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200131/ScreenRecording_02-27-2569_20-44-13_1_gpauqt.mp4", 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),   
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            
        ],
        requiredSettings: [
            
        ],
        successMessage: "Just trust the process!",
        nextLevelViewName: "Level5_2",
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

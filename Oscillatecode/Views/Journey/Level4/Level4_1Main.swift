import SwiftUI

struct Level4_1Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false, 
        midiFilename: nil, 
        midiPlaybackSpeed: nil, 
        availableNodes: ["Oscillator", "Output", "Filter"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Triangle"),
            ("Filter", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Highpass (HP): Blocks bass, lets treble through. \nLowpass (LP): Blocks treble, lets bass through. \nBandpass (BP): Only lets middle frequencies through.",
        playDialogueOnStart: "lv4d1",
        playVideoOnStart: "Lv4-1", 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Filter"),
            LevelConfig.ConnectionGoal(fromType: "Filter", toType: "Output")
        ],
        requiredSettings: [
            
        ],
        successMessage: "Nice! Now let's do something more fun!!",
        nextLevelViewName: "Level4_2",
        requireNoteInput: true
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

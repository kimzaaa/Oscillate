import SwiftUI

struct Level1Main: View {
    
    let config = LevelConfig(
        showKeyboard: false,
        showMidi: false, 
        midiFilename: "level1_melody", 
        midiPlaybackSpeed: 1.0, 
        availableNodes: ["Oscillator", "Output"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine")
        ],
        hintText: "Hold the green orb next to the node, and drag it to the yellow output node",
        playDialogueOnStart: "lv1d1",
        playVideoOnStart: "Lv1", 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Output")
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

import SwiftUI

struct Level3_1Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false, 
        midiFilename: nil, 
        midiPlaybackSpeed: nil, 
        availableNodes: ["Oscillator", "Output", "Pitch"], 
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("Pitch", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Try Adjusting the sliders",
        playDialogueOnStart: "lv3d1",
        playVideoOnStart: "Lv3-1", 
        videoSize: CGSize(width: 1200, height: 500),
        
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "Pitch"),
            LevelConfig.ConnectionGoal(fromType: "Pitch", toType: "Output")
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

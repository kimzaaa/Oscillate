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
        playVideoOnStart: "https://res.cloudinary.com/dpduyofon/video/upload/v1772200126/ScreenRecording_02-27-2569_20-40-57_1_urx6xe.mp4", 
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

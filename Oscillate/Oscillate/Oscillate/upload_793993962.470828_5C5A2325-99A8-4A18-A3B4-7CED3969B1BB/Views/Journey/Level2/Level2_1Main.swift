import SwiftUI

struct Level2_1Main: View {
    
    let config = LevelConfig(
        showKeyboard: false,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "ADSR", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("ADSR", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "A sound can shape with a help of other modules in one track",
        playDialogueOnStart: "lv2d1",
        playVideoOnStart: "Lv2-1",
        videoSize: CGSize(width: 1200, height: 500),
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Now try adjusting the sliders",
        nextLevelViewName: "Level2_2", 
        requireNoteInput: false
    )
    
    var body: some View {
        SynthLevelView(config: config)
    }
}

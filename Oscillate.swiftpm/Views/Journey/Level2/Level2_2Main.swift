import SwiftUI

struct Level2_2Main: View {
    
    let config = LevelConfig(
        showKeyboard: true,
        showMidi: false,
        midiFilename: nil,
        midiPlaybackSpeed: nil,
        availableNodes: ["Oscillator", "ADSR", "Output"],
        initialNodes: [
            ("Oscillator", CGPoint(x: 200, y: 300), "Sine"),
            ("ADSR", CGPoint(x: 500, y: 300), nil)
        ],
        hintText: "Attack: How fast the sound hits full volume.  (Short = Sharp / Long = Swell) \nDecay: How fast the sound drops to its steady level. (Short = Quick drop / Long = Smooth fade) \nSustain: How loud the sound stays while you hold the note. (High = Bright & Constant / Low = Quiet & Soft) \nRelease: How long the sound lingers after you let go. (Short = Instant stop / Long = Echoing trail)",
        playDialogueOnStart: nil,
        playVideoOnStart: nil,
        videoSize: nil,
        requiredConnections: [
            LevelConfig.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfig.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Now try making a pluck sound",
        nextLevelViewName: "Level2_3", 
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

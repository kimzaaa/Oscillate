import SwiftUI

struct Level2_2Main: View {
    // Level 1-1 configuration
    // Example: Maybe now they need to change the waveform
    let config = LevelConfiguration(
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
            LevelConfiguration.ConnectionGoal(fromType: "Oscillator", toType: "ADSR"),
            LevelConfiguration.ConnectionGoal(fromType: "ADSR", toType: "Output")
        ],
        requiredSettings: [],
        successMessage: "Now try making a pluck sound",
        nextLevelViewName: "Level2_3", // Assuming new level
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



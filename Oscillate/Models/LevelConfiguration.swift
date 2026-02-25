import Foundation
import CoreGraphics

struct LevelConfiguration {
    /// Whether to show the piano keyboard at the bottom
    let showKeyboard: Bool
    
    /// Whether to show MIDI controls
    let showMidi: Bool
    
    /// If non-nil, use this specific MIDI file from the bundle instead of a picker
    let midiFilename: String?
    
    /// If non-nil, force this playback speed (hide slider)
    let midiPlaybackSpeed: Double?
    
    /// List of node types allowed in the toolbar
    /// e.g. ["Oscillator", "ADSR", "Filter", "Reverb", "Resonance", "Pitch"]
    let availableNodes: [String]
    
    /// Nodes to spawn immediately upon loading the level
    /// e.g. [("Oscillator", CGPoint(x: 300, y: 300))]
    let initialNodes: [(type: String, position: CGPoint)]
    
    /// Text to show when the hint button is pressed
    let hintText: String?
    
    /// Audio file to play on start (e.g. "intro_dialogue.mp3")
    let playDialogueOnStart: String?
    
    /// Video file to play on start (e.g. "intro_video.mp4")
    let playVideoOnStart: String?
    
    /// Size of the video player
    let videoSize: CGSize?
    
    // MARK: - Level Goal System
    
    /// Defines a required connection between two node types
    struct ConnectionGoal {
        let fromType: String // e.g. "Oscillator"
        let toType: String   // e.g. "Output"
    }
    
    /// Defines required settings for a specific node type
    struct SettingGoal {
        let nodeType: String        // e.g. "Oscillator"
        let settingName: String     // e.g. "waveform", "frequency", "cutoff"
        let targetValue: Double     // The expected value (use 0/1 for enums if needed, or mapping)
        let tolerance: Double?      // Allowable difference (+/-). If nil, must be exact (or string match)
    }
    
    /// The conditions required to "beat" this level
    let requiredConnections: [ConnectionGoal]
    let requiredSettings: [SettingGoal]
    
    /// Message to show when goals are met
    let successMessage: String?
    
    /// The name of the next view/level to navigate to
    let nextLevelViewName: String?
    
    // MARK: - Interaction Goals
    /// Check if user has played at least one note on the keyboard
    let requireNoteInput: Bool
}

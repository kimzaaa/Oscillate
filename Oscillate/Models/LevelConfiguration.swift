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
}

import Foundation
import CoreGraphics

struct LevelConfig {
    
    let showKeyboard: Bool
    let showMidi: Bool
    let midiFilename: String?
    let midiPlaybackSpeed: Double?
    let availableNodes: [String]
    let initialNodes: [(type: String, position: CGPoint, waveform: String?)]
    let hintText: String?
    let hintAudioFilename: String? = nil
    let playDialogueOnStart: String?
    let playVideoOnStart: String?
    let videoSize: CGSize?
    
    struct ConnectionGoal {
        let fromType: String 
        let toType: String   
    }

    struct SettingGoal {
        let nodeType: String        
        let settingName: String     
        let targetValue: Double     
        let tolerance: Double?      
    }
    
    let requiredConnections: [ConnectionGoal]
    let requiredSettings: [SettingGoal]
    let successMessage: String?
    let nextLevelViewName: String?
    let requireNoteInput: Bool
}

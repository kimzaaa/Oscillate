import Foundation

struct ShowcaseCard: Identifiable {
    let id = UUID()
    let title: String
    let difficulty: Difficulty
    let description: String
    let videoURL: String // URI string, e.g., "https://..." or a local bundle MP4 name
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

class ShowcaseData {
    static let cards: [ShowcaseCard] = [
        ShowcaseCard(
            title: "Basic Saw Pluck",
            difficulty: .beginner,
            description: "A simple introduction to shaping sounds. Connect a Saw Oscillator into an ADSR envelope. Lower the sustain and decay to create a punchy, staccato sound perfect for basslines or arpeggios.",
            videoURL: "showcase_pluck" // You can replace this with your actual local file or URL later
        ),
        ShowcaseCard(
            title: "Dreamy Chord Pad",
            difficulty: .intermediate,
            description: "Layer multiple oscillators detuned slightly from each other. Run them through a Filter with a slow automated sweep, and bathe it in Reverb to create a lush, atmospheric pad.",
            videoURL: "showcase_pad"
        ),
        ShowcaseCard(
            title: "The 'Resonance' Lead",
            difficulty: .advanced,
            description: "Recreate the iconic synth from HOME's 'Resonance'. This uses 4 Triangle oscillators, mixed with pitch shifting to build chords, and automated filters to give it an evolving, nostalgic wobble.",
            videoURL: "showcase_resonance"
        )
    ]
}

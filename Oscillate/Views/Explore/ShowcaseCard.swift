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
            title: "Basic Pad",
            difficulty: .beginner,
            description: "A Simple pad consists of : \n- x1 Osc\n- x1 ADSR\n- x1 Reverb",
            videoURL: "https://res.cloudinary.com/dpduyofon/video/upload/v1772279563/ScreenRecording_02-28-2569_18-20-18_1_jfgphm.mov"
        ),
        ShowcaseCard(
            title: "EDM Saw",
            difficulty: .intermediate,
            description: "A basic saw sound, common in EDM songs. Consists of : \n- x3 OSC\n- x3 Pitch",
            videoURL: "https://res.cloudinary.com/dpduyofon/video/upload/v1772279563/ScreenRecording_02-28-2569_18-24-01_1_gfkdx2.mov"
        ),
        ShowcaseCard(
            title: "Resonance",
            difficulty: .advanced,
            description: "A synth sound recreated from a popular song by Home. Consists of \n- x4 Osc\n- x4 ADSR\n- x3 Pitch\n- x4 Filter",
            videoURL: "https://res.cloudinary.com/dpduyofon/video/upload/v1772279563/ScreenRecording_02-28-2569_18-07-51_1_oynkeq.mov"
        ),
        ShowcaseCard(
            title: "Subterranean Pulsar",
            difficulty: .expert,
            description: "A Complex sound with hybrid node usage and routing. Consists of \n- x3 Osc\n- x1 ADSR\n- x3 Filter\n- x2 Resonance\n- x1 Reverb",
            videoURL: "https://res.cloudinary.com/dpduyofon/video/upload/v1772279564/ScreenRecording_02-28-2569_18-42-43_1_rpxlkr.mov"
        )
    ]
}

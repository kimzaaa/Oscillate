import SwiftUI
import AVFoundation

class SynthNode: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let color: Color
    let icon: String
    
    @Published var position: CGPoint
    
    var avNode: AVAudioNode?
    
    var inputPosition: CGPoint {
        return CGPoint(x: position.x - 75, y: position.y)
    }
    
    var outputPosition: CGPoint {
        return CGPoint(x: position.x + 75, y: position.y)
    }
    
    init(name: String, color: Color, icon: String, position: CGPoint) {
        self.name = name
        self.color = color
        self.icon = icon
        self.position = position
    }
    
    func content() -> AnyView {
        return AnyView(EmptyView())
    }
}

import SwiftUI

struct WaveformShape: Shape {
    var waveform: OscillatorNode.Waveform
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        switch waveform {
        case .sine:
            for x in stride(from: 0, to: width, by: 1) {
                let relativeX = x / width
                let y = midY - (height / 2) * sin(relativeX * 2 * .pi)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
        case .square:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: width / 2, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            
        case .triangle:
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            
        case .saw:
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height)) // Return to bottom for fill
        }
        
        return path
    }
}

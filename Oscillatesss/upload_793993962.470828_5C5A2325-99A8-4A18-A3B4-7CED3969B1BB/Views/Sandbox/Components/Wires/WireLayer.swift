import SwiftUI

struct WireLayer: View {
    @ObservedObject var viewModel: GridViewModel
    var movingNodeID: UUID?
    var movingOffset: CGSize
    
    var body: some View {
        ZStack {
            ForEach(viewModel.wires) { wire in
                if let startNode = viewModel.nodes.first(where: { $0.id == wire.startNodeID }),
                   let endNode = viewModel.nodes.first(where: { $0.id == wire.endNodeID }) {
                    
                    let startPos = resolvePosition(for: startNode, isOutput: true)
                    let endPos = resolvePosition(for: endNode, isOutput: false)
                    
                    WireInteractiveView(wire: wire, start: startPos, end: endPos) {
                        viewModel.removeWire(wire)
                    }
                }
            }
            
            if let start = viewModel.draggingWireStart, let current = viewModel.draggingWireCurrent {
                BezierWire(start: start, end: current)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, dash: [10]))
                    .allowsHitTesting(false)
            }
        }
    }
    
    func resolvePosition(for node: SynthNode, isOutput: Bool) -> CGPoint {
        var currentPos = node.position
        if node.id == movingNodeID {
            currentPos.x += movingOffset.width
            currentPos.y += movingOffset.height
        }
        let xOffset = isOutput ? 75 : -75
        return CGPoint(x: currentPos.x + CGFloat(xOffset), y: currentPos.y)
    }
}

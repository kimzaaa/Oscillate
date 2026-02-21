import SwiftUI

struct DraggableNode: View {
    let node: SynthNode
    // Removed zoomScale as using coordinateSpace fixes the scaling issue
    var onDragChange: (CGSize) -> Void
    var onMoveEnd: (CGPoint) -> Void
    var onStartWire: (CGPoint) -> Void
    var onUpdateWire: (CGPoint) -> Void
    var onEndWire: () -> Void
    var onRemove: () -> Void
    
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        NodeView(node: node)
            .overlay(wireDragOverlay, alignment: .trailing)
            .overlay(inputIndicator, alignment: .leading)
            .offset(dragOffset)
            .position(node.position)
            .onTapGesture(count: 2) {
                onRemove()
            }
            .gesture(
                // Kept minimumDistance: 10 to allow Sliders inside NodeView to work
                DragGesture(minimumDistance: 10, coordinateSpace: .named("CanvasSpace"))
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { value in
                        onDragChange(value.translation)
                    }
                    .onEnded { value in
                        let newPoint = CGPoint(
                            x: node.position.x + value.translation.width,
                            y: node.position.y + value.translation.height
                        )
                        onMoveEnd(newPoint)
                    }
            )
    }
    
    var wireDragOverlay: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 25, height: 25)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: 12, y: 0)
            .highPriorityGesture(
                DragGesture(coordinateSpace: .named("CanvasSpace"))
                    .onChanged { value in
                        let currentPos = CGPoint(
                            x: node.position.x + dragOffset.width,
                            y: node.position.y + dragOffset.height
                        )
                        let outputPos = CGPoint(x: currentPos.x + 75, y: currentPos.y)
                        onStartWire(outputPos)
                        onUpdateWire(value.location)
                    }
                    .onEnded { _ in onEndWire() }
            )
    }
    
    var inputIndicator: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 15, height: 15)
            .offset(x: -8, y: 0)
    }
}

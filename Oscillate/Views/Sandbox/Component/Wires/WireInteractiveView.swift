import SwiftUI

struct WireInteractiveView: View {
    let wire: Wire
    let start: CGPoint
    let end: CGPoint
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            // Touch Target (Thick invisible line)
            // Note: Removed contentShape() because stroking the shape directly works better for hit testing
            BezierWire(start: start, end: end)
                .stroke(Color.white.opacity(0.01), lineWidth: 30) // Increased width for easier tapping
                .onTapGesture(count: 2) {
                    onRemove()
                }
            
            // Visual Wire
            BezierWire(start: start, end: end)
                .stroke(Color.gray, lineWidth: 3)
                .allowsHitTesting(false)
        }
    }
}

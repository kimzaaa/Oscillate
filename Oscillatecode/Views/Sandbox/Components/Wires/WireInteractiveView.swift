import SwiftUI

struct WireInteractiveView: View {
    let wire: Wire
    let start: CGPoint
    let end: CGPoint
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            
            BezierWire(start: start, end: end)
                .stroke(Color.white.opacity(0.01), lineWidth: 30) 
                .onTapGesture(count: 2) {
                    onRemove()
                }
            
            BezierWire(start: start, end: end)
                .stroke(Color.gray, lineWidth: 3)
                .allowsHitTesting(false)
        }
    }
}

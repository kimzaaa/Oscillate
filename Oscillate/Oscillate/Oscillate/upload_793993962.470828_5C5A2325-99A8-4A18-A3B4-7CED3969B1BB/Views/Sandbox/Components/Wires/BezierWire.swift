import SwiftUI

struct BezierWire: Shape {
    var start: CGPoint
    var end: CGPoint
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        let control1 = CGPoint(x: start.x + 50, y: start.y)
        let control2 = CGPoint(x: end.x - 50, y: end.y)
        path.addCurve(to: end, control1: control1, control2: control2)
        return path
    }
}

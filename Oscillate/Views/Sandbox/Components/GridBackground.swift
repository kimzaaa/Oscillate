import SwiftUI

struct GridBackground: View {
    var gridSize: CGFloat = 75
    var pan: CGSize
    var zoom: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let scaledSpacing = gridSize * zoom
            guard scaledSpacing > 5 else { return }
            
            // Grid Color
            let gridColor = Color.gray.opacity(0.1)
            
            let startCol = Int((-pan.width / scaledSpacing).rounded(.down)) - 1
            let endCol = Int(((size.width - pan.width) / scaledSpacing).rounded(.up)) + 1
            
            for col in startCol...endCol {
                let x = CGFloat(col) * scaledSpacing + pan.width
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(gridColor), lineWidth: 1)
            }
            
            let startRow = Int((-pan.height / scaledSpacing).rounded(.down)) - 1
            let endRow = Int(((size.height - pan.height) / scaledSpacing).rounded(.up)) + 1
            
            for row in startRow...endRow {
                let y = CGFloat(row) * scaledSpacing + pan.height
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(gridColor), lineWidth: 1)
            }
        }
        .drawingGroup() 
    }
}
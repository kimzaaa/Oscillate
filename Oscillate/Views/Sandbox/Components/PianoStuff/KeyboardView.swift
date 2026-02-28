import SwiftUI

struct KeyboardView: View {
    let octaveStart: Int = 4
    let noteCount: Int = 36 
    
    var onNoteOn: (Float) -> Void
    var onNoteOff: (Float) -> Void
    
    @State private var activeNotes: Set<Int> = []
    
    func frequency(for noteIndex: Int) -> Float {
        
        let baseC4: Float = 261.63
        return baseC4 * pow(2.0, Float(noteIndex) / 12.0)
    }
    
    func isBlackKey(_ index: Int) -> Bool {
        let noteInOctave = index % 12
        return [1, 3, 6, 8, 10].contains(noteInOctave)
    }
    
    func whiteKeyIndex(for noteIndex: Int) -> Int {
        var count = -1
        for i in 0..<noteIndex {
            if !isBlackKey(i) {
                count += 1
            }
        }
        return count
    }
    
    var whiteKeyCount: Int {
        var count = 0
        for i in 0..<noteCount {
            if !isBlackKey(i) {
                count += 1
            }
        }
        return count
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let availableWidth = width - 4
            let whiteKeyWidth = availableWidth / CGFloat(whiteKeyCount)
            let blackKeyWidth = whiteKeyWidth * 0.65
            let blackKeyHeight = height * 0.6
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: width, height: height)
                
                HStack(spacing: 1) { 
                    ForEach(0..<noteCount, id: \.self) { i in
                        if !isBlackKey(i) {
                            Rectangle()
                                .fill(activeNotes.contains(i) ? Color.yellow.opacity(0.8) : Color.white)
                                .frame(width: (availableWidth / CGFloat(whiteKeyCount)) - 1, height: height - 4) 
                            
                                .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                        }
                    }
                }
                .padding(2) 
                
                ForEach(0..<noteCount, id: \.self) { i in
                    if isBlackKey(i) {
                        let whiteIndexObj = whiteKeyIndex(for: i)
                        
                        let centeredOffset = (CGFloat(whiteIndexObj) * whiteKeyWidth) + whiteKeyWidth - (blackKeyWidth / 2)
                        
                        Rectangle()
                            .fill(activeNotes.contains(i) ? Color.gray : Color.black)
                            .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                            .frame(width: blackKeyWidth, height: blackKeyHeight)
                            .position(x: centeredOffset + 2 + (blackKeyWidth/2), y: 2 + (blackKeyHeight/2)) 
                    }
                }
                
                MultiTouchPianoView(
                    noteCount: noteCount,
                    onNoteOn: { noteIndex in
                        activeNotes.insert(noteIndex)
                        onNoteOn(frequency(for: noteIndex))
                    },
                    onNoteOff: { noteIndex in
                        activeNotes.remove(noteIndex)
                        onNoteOff(frequency(for: noteIndex))
                    },
                    isBlackKey: isBlackKey,
                    getWhiteKeyIndex: whiteKeyIndex,
                    whiteKeyCount: whiteKeyCount
                )
            }
            
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 2)
                    .allowsHitTesting(false) 
            )
            .cornerRadius(10)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

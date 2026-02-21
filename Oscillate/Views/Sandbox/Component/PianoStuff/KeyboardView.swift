import SwiftUI

struct KeyboardView: View {
    let octaveStart: Int = 4
    let noteCount: Int = 36 // Increased to 3 octaves for narrower keys
    
    var onNoteOn: (Float) -> Void
    var onNoteOff: (Float) -> Void
    
    // State to track currently playing notes
    @State private var activeNotes: Set<Int> = []
    
    // MIDI Note number to Frequency
    func frequency(for noteIndex: Int) -> Float {
        // C4 (MIDI 60) is at index 0
        // C4 = 261.63 Hz
        let baseC4: Float = 261.63
        return baseC4 * pow(2.0, Float(noteIndex) / 12.0)
    }
    
    // Check if a note index corresponds to a black key
    func isBlackKey(_ index: Int) -> Bool {
        let noteInOctave = index % 12
        return [1, 3, 6, 8, 10].contains(noteInOctave)
    }

    // Get the white key index (0, 1, 2...) for a given absolute key index
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
            // Subtract padding when calculating width
            let availableWidth = width - 4
            let whiteKeyWidth = availableWidth / CGFloat(whiteKeyCount)
            let blackKeyWidth = whiteKeyWidth * 0.65
            let blackKeyHeight = height * 0.6
            
            ZStack(alignment: .topLeading) {
                // Background fills the gaps between keys (making lines black)
                Rectangle()
                    .fill(Color.black)
                    .frame(width: width, height: height)
                
                // --- White Keys ---
                HStack(spacing: 1) { // 1px spacing for border effect
                    ForEach(0..<noteCount, id: \.self) { i in
                        if !isBlackKey(i) {
                            Rectangle()
                                .fill(activeNotes.contains(i) ? Color.yellow.opacity(0.8) : Color.white)
                                .frame(width: (availableWidth / CGFloat(whiteKeyCount)) - 1, height: height - 4) // adjust height for padding
                                // Add corner radius only at bottom
                                .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                        }
                    }
                }
                .padding(2) // Outer border padding
                
                // --- Black Keys ---
                // We overlay black keys at specific positions
                ForEach(0..<noteCount, id: \.self) { i in
                    if isBlackKey(i) {
                        let whiteIndexObj = whiteKeyIndex(for: i)
                        // Position relative to the start of the white keys container (which is at x=2)
                        let centeredOffset = (CGFloat(whiteIndexObj) * whiteKeyWidth) + whiteKeyWidth - (blackKeyWidth / 2)
                        
                        Rectangle()
                            .fill(activeNotes.contains(i) ? Color.gray : Color.black)
                            .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                            .frame(width: blackKeyWidth, height: blackKeyHeight)
                            .position(x: centeredOffset + 2 + (blackKeyWidth/2), y: 2 + (blackKeyHeight/2)) 
                    }
                }
                
                // --- Multi-Touch Interaction Layer ---
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
            // removed .gesture()
            // Add a white border around the entire piano
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 2)
                    .allowsHitTesting(false) // Pass touches to underlying view
            )
            .cornerRadius(10)
        }
    }
}

// Helper for rounded corners
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

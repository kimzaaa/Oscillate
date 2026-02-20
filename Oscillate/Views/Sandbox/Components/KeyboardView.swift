import SwiftUI

struct KeyboardView: View {
    let octave: Int = 4
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    var onNoteOn: (Float) -> Void
    var onNoteOff: (Float) -> Void
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<24) { i in
                KeyButton(
                    noteName: noteNames[i % 12],
                    octave: octave + (i / 12),
                    index: i,
                    onNoteOn: onNoteOn,
                    onNoteOff: onNoteOff
                )
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
    }
}

struct KeyButton: View {
    let noteName: String
    let octave: Int
    let index: Int
    var onNoteOn: (Float) -> Void
    var onNoteOff: (Float) -> Void
    
    @State private var isPressed: Bool = false
    
    var isBlackKey: Bool {
        return noteName.contains("#")
    }
    
    var frequency: Float {
        // A4 = 440Hz at index 9 (if starting C=0)
        // Frequency = 440 * 2^((n - 9) / 12)  for 4th octave relative to A4
        // But relative to C4 (MIDI 60), A4 is 69.
        // n is semitone offset from A4.
        
        // Simpler: base frequency for C4 is ~261.63 Hz
        // freq = 261.63 * 2^(i/12)
        let baseC4: Float = 261.63
        return baseC4 * pow(2.0, Float(index) / 12.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(isPressed ? (isBlackKey ? Color.gray : Color.yellow) : (isBlackKey ? Color.black : Color.white))
                    .cornerRadius(4)
                
                if !isBlackKey {
                    VStack {
                        Spacer()
                        Text(noteName)
                            .font(.caption)
                            .foregroundColor(isPressed ? .black : .black)
                            .padding(.bottom, 5)
                    }
                }
            }
            // Use available height. Black keys are 60% of height.
            .frame(height: isBlackKey ? geometry.size.height * 0.6 : geometry.size.height)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        // Remove fixed frame
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onNoteOn(frequency)
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onNoteOff(frequency)
                }
        )
    }
}

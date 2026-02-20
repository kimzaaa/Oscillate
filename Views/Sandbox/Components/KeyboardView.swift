import SwiftUI

struct KeyboardView: View {
    let octave: Int = 4
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    var onNoteOn: (Float) -> Void
    var onNoteOff: (Float) -> Void
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<12) { i in
                KeyButton(noteName: noteNames[i], octave: octave, index: i, onNoteOn: onNoteOn, onNoteOff: onNoteOff)
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
        ZStack {
            Rectangle()
                .fill(isPressed ? (isBlackKey ? Color.gray : Color.yellow) : (isBlackKey ? Color.black : Color.white))
                .cornerRadius(4)
                .frame(width: isBlackKey ? 30 : 40, height: isBlackKey ? 80 : 120) // Black keys shorter
            
            VStack {
                Spacer()
                Text(noteName)
                    .font(.caption)
                    .foregroundColor(isPressed ? .black : (isBlackKey ? .white : .black))
                    .padding(.bottom, 5)
            }
        }
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
        // Adjust z-index for black keys to sit on top if overlapping (layout logic needed for real piano)
        // But here we just use HStack so they are side-by-side which is not a real piano layout.
        // A real piano layout has black keys between white keys.
        // For "1 octet keyboard", simple buttons are fine for now unless user insists on real layout.
        // The user said "1 octet keyboard".
        // I will implement a linear layout for simplicity but mark black keys.
    }
}

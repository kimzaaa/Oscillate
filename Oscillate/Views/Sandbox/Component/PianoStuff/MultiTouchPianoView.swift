import SwiftUI
import UIKit

struct MultiTouchPianoView: UIViewRepresentable {
    var noteCount: Int
    var onNoteOn: (Int) -> Void
    var onNoteOff: (Int) -> Void
    var isBlackKey: (Int) -> Bool
    var getWhiteKeyIndex: (Int) -> Int
    var whiteKeyCount: Int
    
    class Coordinator: NSObject {
        var parent: MultiTouchPianoView
        
        init(_ parent: MultiTouchPianoView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PianoTouchUIView {
        let view = PianoTouchUIView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.coordinator = context.coordinator
        view.noteCount = noteCount
        view.whiteKeyCount = whiteKeyCount
        return view
    }
    
    func updateUIView(_ uiView: PianoTouchUIView, context: Context) {
        context.coordinator.parent = self
        // Update properties on the view
        uiView.noteCount = noteCount
        uiView.whiteKeyCount = whiteKeyCount
        uiView.setNeedsLayout()
    }
    
    class PianoTouchUIView: UIView {
        weak var coordinator: Coordinator?
        
        var noteCount: Int = 0
        var whiteKeyCount: Int = 0
        
        // Map from MIDI note index to its hit-test frame
        private var keyFrames: [Int: CGRect] = [:]
        
        // Cache the black key set for faster lookup
        private var blackKeys: Set<Int> = []
        
        // Map touch -> Note currently playing
        private var activeTouches = [UITouch: Int]()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            computeKeyFrames()
        }
        
        private func computeKeyFrames() {
            guard let parent = coordinator?.parent, parent.whiteKeyCount > 0 else { return }
            
            keyFrames.removeAll()
            blackKeys.removeAll()
            
            let w = bounds.width
            let h = bounds.height
            
            // Match layout logic from KeyboardView
            let padding: CGFloat = 2
            let availableWidth = w - (padding * 2)
            let whiteKeyWidth = availableWidth / CGFloat(parent.whiteKeyCount)
            let blackKeyWidth = whiteKeyWidth * 0.65
            let blackKeyHeight = h * 0.6
            
            var currentWhiteIndex = 0
            
            // First pass: Calculate frames for all keys based on their index
            for noteIndex in 0..<parent.noteCount {
                if parent.isBlackKey(noteIndex) {
                    blackKeys.insert(noteIndex)
                    
                    // Logic from KeyboardView for Black Key Position:
                    // whiteKeyIndex(for: i) returns the count of white keys BEFORE this note.
                    // If note is C#4 (index 1), loop 0..<1. i=0 is white. count=0. Returns 0.
                    // KeyboardView: let centeredOffset = (CGFloat(whiteIndexObj) * whiteKeyWidth) + whiteKeyWidth - (blackKeyWidth / 2)
                    
                    let whiteIndexIndex = parent.getWhiteKeyIndex(noteIndex)
                    // Calculate centered offset for black key
                    // Matches KeyboardView logic: (count * width) + width - (blackWidth / 2)
                    let centeredOffset = (CGFloat(whiteIndexIndex) * whiteKeyWidth) + whiteKeyWidth - (blackKeyWidth / 2)
                    
                    // The KeyboardView applies .padding(2) to the HStack, so x starts at 2
                    let x = padding + centeredOffset
                    let rect = CGRect(x: x, y: padding, width: blackKeyWidth, height: blackKeyHeight)
                    keyFrames[noteIndex] = rect
                    
                } else {
                    // White Key Position
                    // They are stacked in HStack(spacing: 1).
                    // x = padding + (index * inputWidth)
                    // But effectively, they take up 'whiteKeyWidth' stride.
                    
                    let x = padding + (CGFloat(currentWhiteIndex) * whiteKeyWidth)
                    // For hit testing, we use the full stride width to cover the 1px gap
                    let rect = CGRect(x: x, y: padding, width: whiteKeyWidth, height: h - (padding * 2))
                    keyFrames[noteIndex] = rect
                    
                    currentWhiteIndex += 1
                }
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            processTouches(touches)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            processTouches(touches)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            cleanupTouches(touches)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            cleanupTouches(touches)
        }
        
        private func cleanupTouches(_ touches: Set<UITouch>) {
            guard let parent = coordinator?.parent else { return }
            for touch in touches {
                if let note = activeTouches[touch] {
                    parent.onNoteOff(note)
                    activeTouches.removeValue(forKey: touch)
                }
            }
        }
        
        private func processTouches(_ touches: Set<UITouch>) {
            guard let parent = coordinator?.parent else { return }
            
            // We need to re-evaluate ALL active touches, because a finger might slide
            // from one key to another. The 'touches' argument only contains *changed* touches.
            // But for a piano, if you slide, the touch "moves".
            
            for touch in touches {
                let location = touch.location(in: self)
                var hitNote: Int? = nil
                
                // 1. Check Black Keys (Visual Z-Index: Top)
                // Filter keyFrames for black keys
                for (note, rect) in keyFrames where blackKeys.contains(note) {
                    if rect.contains(location) {
                        hitNote = note
                        break
                    }
                }
                
                // 2. Check White Keys if no black key hit
                if hitNote == nil {
                    for (note, rect) in keyFrames where !blackKeys.contains(note) {
                        if rect.contains(location) {
                            hitNote = note
                            break
                        }
                    }
                }
                
                // State Update Logic
                let oldNote = activeTouches[touch]
                
                if let newNote = hitNote {
                    if oldNote != newNote {
                        // Changed key
                        if let old = oldNote { parent.onNoteOff(old) }
                        parent.onNoteOn(newNote)
                        activeTouches[touch] = newNote
                    }
                    // If oldNote == newNote, do nothing (still holding same key)
                } else {
                    // Moved off keyboard
                    if let old = oldNote {
                        parent.onNoteOff(old)
                        activeTouches.removeValue(forKey: touch)
                    }
                }
            }
        }
    }
}
import Foundation
import Combine

class MidiSequencer: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentFile: URL?
    @Published var playbackSpeed: Double = 1.0 // 0.1x to 5.0x
    
    private var events: [MidiEvent] = []
    private var timer: Timer?
    private var lastUpdateTime: TimeInterval = 0
    private var songPosition: TimeInterval = 0
    private var eventIndex: Int = 0
    
    var onNoteOn: ((Float) -> Void)?
    var onNoteOff: ((Float) -> Void)?
    
    func load(url: URL) {
        let parser = SimpleMidiParser()
        if let loadedEvents = parser.parse(url: url) {
            self.events = loadedEvents
            self.currentFile = url
            print("Loaded \(events.count) MIDI events")
        }
    }
    
    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }
    
    func play() {
        guard !events.isEmpty else { return }
        isPlaying = true
        eventIndex = 0
        songPosition = 0
        lastUpdateTime = Date().timeIntervalSince1970
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] _ in
            self?.processEvents()
        }
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        // All Notes Off could be sent here if we tracked active notes
    }
    
    private func processEvents() {
        guard eventIndex < events.count else {
            stop()
            return
        }
        
        let now = Date().timeIntervalSince1970
        let delta = now - lastUpdateTime
        lastUpdateTime = now
        
        // Advance song position by elapsed real time * speed
        songPosition += delta * playbackSpeed
        
        while eventIndex < events.count {
            let event = events[eventIndex]
            if event.timestamp <= songPosition {
                // Trigger event
                // Convert MIDI note to Frequency
                let freq = SimpleMidiParser.frequency(for: event.note)
                
                if event.type == .noteOn {
                    onNoteOn?(freq)
                } else {
                    onNoteOff?(freq)
                }
                
                eventIndex += 1
            } else {
                break
            }
        }
    }
}

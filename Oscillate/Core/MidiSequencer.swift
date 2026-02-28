import Foundation
import Combine

class MidiSequencer: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentFile: URL?
    @Published var playbackSpeed: Double = 1.0 
    
    private var events: [MidiEvent] = []
    private var timer: Timer?
    private var lastUpdateTime: TimeInterval = 0
    private var songPosition: TimeInterval = 0
    private var eventIndex: Int = 0
    private var activeNotes = Set<Float>()
    
    var onNoteOn: ((Float) -> Void)?
    var onNoteOff: ((Float) -> Void)?
    
    func load(url: URL) {
        let parser = SimpleMidiParser()
        if let loadedEvents = parser.parse(url: url) {
            self.events = loadedEvents
            self.currentFile = url
            
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
        
        for note in activeNotes {
            onNoteOff?(note)
        }
        activeNotes.removeAll()
    }
    
    private func processEvents() {
        guard eventIndex < events.count else {
            stop()
            return
        }
        
        let now = Date().timeIntervalSince1970
        let delta = now - lastUpdateTime
        lastUpdateTime = now
        
        songPosition += delta * playbackSpeed
        
        while eventIndex < events.count {
            let event = events[eventIndex]
            if event.timestamp <= songPosition {
                
                let freq = SimpleMidiParser.frequency(for: event.note)
                
                if event.type == .noteOn {
                    activeNotes.insert(freq)
                    onNoteOn?(freq)
                } else {
                    activeNotes.remove(freq)
                    onNoteOff?(freq)
                }
                
                eventIndex += 1
            } else {
                break
            }
        }
    }
}
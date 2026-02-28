import SwiftUI
import AVFoundation

class GridViewModel: ObservableObject {
    @Published var nodes: [SynthNode] = []
    @Published var wires: [Wire] = []
    
    @Published var draggingWireStart: CGPoint?
    @Published var draggingWireCurrent: CGPoint?
    @Published var draggingSourceID: UUID?
    
    let engine = AudioEngine.shared.engine
    private var connectionSFXPlayer: AVAudioPlayer?
    
    init() {
        
        let out = OutputNode(position: CGPoint(x: 900, y: 300))
        nodes = [out]
        
        if let av = out.avNode, av !== engine.mainMixerNode {
            engine.attach(av)
        }
    }
    
    func spawnNode(type: String, at position: CGPoint? = nil, waveform: String? = nil) {
        let spawnPoint = position ?? CGPoint(x: 300, y: 300)
        var newNode: SynthNode?
        
        switch type {
        case "Oscillator":
            let osc = OscillatorNode(position: spawnPoint)
            if let waveformRaw = waveform {
                switch waveformRaw.lowercased() {
                case "sine": osc.waveform = .sine
                case "square": osc.waveform = .square
                case "triangle": osc.waveform = .triangle
                case "saw": osc.waveform = .saw
                default: break
                }
            }
            newNode = osc
        case "ADSR": newNode = ADSRNode(position: spawnPoint)
        case "Resonance": newNode = ResonanceNode(position: spawnPoint)
        case "Reverb": newNode = ReverbNode(position: spawnPoint)
        case "Filter": newNode = FilterNode(position: spawnPoint)
        case "Pitch": newNode = PitchPanNode(position: spawnPoint)
        case "Output": newNode = OutputNode(position: spawnPoint)
        default: return
        }
        
        if let node = newNode {
            if let av = node.avNode { 
                
                if av !== engine.mainMixerNode {
                    engine.attach(av) 
                }
            }
            DispatchQueue.main.async { self.nodes.append(node) }
        }
    }
    
    func setupLevel(config: LevelConfig) {
        
        self.nodes.removeAll()
        self.wires.removeAll()
        
        let out = OutputNode(position: CGPoint(x: 900, y: 300))
        if let av = out.avNode, av !== engine.mainMixerNode {
            engine.attach(av)
        }
        self.nodes.append(out)
        
        for (type, pos, waveform) in config.initialNodes {
            spawnNode(type: type, at: pos, waveform: waveform)
        }
    }
    
    func noteOn(frequency: Float) {
        for node in nodes {
            if let osc = node as? OscillatorNode {
                osc.noteOn(frequency: frequency)
            } else if let adsr = node as? ADSRNode {
                adsr.noteOn()
            } else if let filter = node as? FilterNode {
                filter.noteOn()
            }
        }
    }
    
    func noteOff(frequency: Float) {
        for node in nodes {
            if let osc = node as? OscillatorNode {
                osc.noteOff(frequency: frequency)
            } else if let adsr = node as? ADSRNode {
                adsr.noteOff()
            } else if let filter = node as? FilterNode {
                filter.noteOff()
            }
        }
    }
    
    func updateNodePosition(id: UUID, newPosition: CGPoint) {
        if let index = nodes.firstIndex(where: { $0.id == id }) {
            nodes[index].position = newPosition
        }
    }
    
    func startWireDrag(from nodeID: UUID, at location: CGPoint) {
        draggingSourceID = nodeID
        draggingWireStart = location
        draggingWireCurrent = location
    }
    
    func updateWireDrag(to location: CGPoint) {
        draggingWireCurrent = location
    }
    
    func endWireDrag() {
        guard let sourceID = draggingSourceID, let currentLoc = draggingWireCurrent else {
            resetDrag()
            return
        }
        
        for node in nodes {
            if node.id != sourceID {
                
                let inputPos = CGPoint(x: node.position.x - 75, y: node.position.y)
                let dist = hypot(currentLoc.x - inputPos.x, currentLoc.y - inputPos.y)
                if dist < 40 {
                    let newWire = Wire(startNodeID: sourceID, endNodeID: node.id)
                    wires.append(newWire)
                    connectAudio(sourceID: sourceID, destID: node.id)
                    playConnectionSFX()
                    break
                }
            }
        }
        resetDrag()
    }
    
    private func connectAudio(sourceID: UUID, destID: UUID) {
        guard let sourceNode = nodes.first(where: { $0.id == sourceID }),
              let destNode = nodes.first(where: { $0.id == destID }),
              let avSource = sourceNode.avNode,
              let avDest = destNode.avNode else { return }
        
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        if !engine.isRunning { try? engine.start() }
        
        engine.connect(avSource, to: avDest, format: format)
    }
    
    private func playConnectionSFX() {
        if connectionSFXPlayer == nil {
            let resourceName = "wire_connect"
            let supportedExtensions = ["wav", "m4a", "mp3", "caf", "aiff"]
            
            guard let url = supportedExtensions
                .compactMap({ Bundle.main.url(forResource: resourceName, withExtension: $0) })
                .first else {
                return
            }
            
            connectionSFXPlayer = try? AVAudioPlayer(contentsOf: url)
            connectionSFXPlayer?.prepareToPlay()
        }
        
        connectionSFXPlayer?.currentTime = 0
        connectionSFXPlayer?.play()
    }
    
    func removeWire(_ wire: Wire) {
        if let sourceNode = nodes.first(where: { $0.id == wire.startNodeID }),
           let avSource = sourceNode.avNode {
            engine.disconnectNodeOutput(avSource)
        }
        wires.removeAll { $0.id == wire.id }
    }
    
    func removeNode(_ id: UUID) {
        if let node = nodes.first(where: {$0.id == id}), node is OutputNode {
            return
        }
        let connectedWires = wires.filter { $0.startNodeID == id || $0.endNodeID == id }
        for wire in connectedWires {
            removeWire(wire)
        }
        
        if let nodeIndex = nodes.firstIndex(where: { $0.id == id }) {
            let node = nodes[nodeIndex]
            if let avNode = node.avNode {
                engine.detach(avNode)
            }
            nodes.remove(at: nodeIndex)
        }
    }
    
    private func resetDrag() {
        draggingWireStart = nil
        draggingWireCurrent = nil
        draggingSourceID = nil
    }
}

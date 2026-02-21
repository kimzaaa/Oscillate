import SwiftUI
import AVFoundation

class GridViewModel: ObservableObject {
    @Published var nodes: [SynthNode] = []
    @Published var wires: [Wire] = []
    
    @Published var draggingWireStart: CGPoint?
    @Published var draggingWireCurrent: CGPoint?
    @Published var draggingSourceID: UUID?
    
    let engine = AudioEngine.shared.engine
    
    init() {
        // Keeping your original "plop" for the output node
        let out = OutputNode(position: CGPoint(x: 900, y: 300))
        nodes = [out]
        
        // Output node is already attached to mainMixer in its class, 
        // but we ensure it's in the engine context
        if let av = out.avNode, av !== engine.mainMixerNode {
            engine.attach(av)
        }
    }
    
    // NEW: Function for the Toolbar to call
    func spawnNode(type: String) {
        let spawnPoint = CGPoint(x: 300, y: 300)
        var newNode: SynthNode?
        
        switch type {
        case "Oscillator": newNode = OscillatorNode(position: spawnPoint)
        case "ADSR": newNode = ADSRNode(position: spawnPoint)
        case "Resonance": newNode = ResonanceNode(position: spawnPoint)
        case "Reverb": newNode = ReverbNode(position: spawnPoint)
        case "Distortion": newNode = DistortionNode(position: spawnPoint)
        case "Pitch": newNode = PitchPanNode(position: spawnPoint)
        default: return
        }
        
        if let node = newNode {
            if let av = node.avNode { engine.attach(av) }
            DispatchQueue.main.async { self.nodes.append(node) }
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
                // Adjusting based on your node width (150)
                let inputPos = CGPoint(x: node.position.x - 75, y: node.position.y)
                let dist = hypot(currentLoc.x - inputPos.x, currentLoc.y - inputPos.y)
                if dist < 40 {
                    let newWire = Wire(startNodeID: sourceID, endNodeID: node.id)
                    wires.append(newWire)
                    connectAudio(sourceID: sourceID, destID: node.id)
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
    
    func removeWire(_ wire: Wire) {
        if let sourceNode = nodes.first(where: { $0.id == wire.startNodeID }),
           let avSource = sourceNode.avNode {
            engine.disconnectNodeOutput(avSource)
        }
        wires.removeAll { $0.id == wire.id }
    }
    
    func removeNode(_ id: UUID) {
        // Remove connected wires first
        let connectedWires = wires.filter { $0.startNodeID == id || $0.endNodeID == id }
        for wire in connectedWires {
            removeWire(wire)
        }
        
        // Remove the node itself
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

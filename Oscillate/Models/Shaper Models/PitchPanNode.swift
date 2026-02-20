import AVFoundation
import SwiftUI

class PitchPanNode: SynthNode {
    var pitchUnit: AVAudioUnitTimePitch
    // Store the base and fine values to keep them persistent
    var basePitch: Float = 0.0
    var finePitch: Float = 0.0
    
    init(position: CGPoint) {
        self.pitchUnit = AVAudioUnitTimePitch()
        self.pitchUnit.pitch = 0.0
        
        super.init(name: "Pitch Shift", color: .purple, icon: "tuningfork", position: position)
        self.avNode = pitchUnit
    }
    
    func updateInternalPitch() {
        self.pitchUnit.pitch = basePitch + finePitch
    }
    
    override func content() -> AnyView {
        AnyView(PitchPanNodeView(node: self))
    }
}

struct PitchPanNodeView: View {
    @ObservedObject var node: PitchPanNode
    
    // We use State to drive the UI, but sync it to the node
    @State private var basePitch: Double
    @State private var finePitch: Double
    
    init(node: PitchPanNode) {
        self.node = node
        _basePitch = State(initialValue: Double(node.basePitch))
        _finePitch = State(initialValue: Double(node.finePitch))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("FINE TUNE").font(.system(size: 8, weight: .bold))
                    Spacer()
                    // Shows the total combined pitch
                    Text("\(Int(basePitch + finePitch)) cts").font(.system(size: 8))
                }
                
                // Slider is strictly -100 to 100
                Slider(value: $finePitch, in: -100...100, step: 1)
                    .accentColor(node.color)
                    .onChange(of: finePitch) { newValue in
                        node.finePitch = Float(newValue)
                        node.updateInternalPitch()
                    }
            }
            
            HStack(spacing: 8) {
                Button(action: { shiftBase(by: -100) }) {
                    Text("-1 TONE").font(.system(size: 7, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Button(action: { shiftBase(by: 100) }) {
                    Text("+1 TONE").font(.system(size: 7, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Button(action: { reset() }) {
                Text("RESET")
                    .font(.system(size: 7, weight: .black))
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(node.color.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Helpful label to see the current base octave/tone
            Text("Base: \(Int(basePitch)) cts")
                .font(.system(size: 6))
                .opacity(0.6)
        }
        .padding(12)
        .frame(width: 150, height: 150) // Increased height slightly for the extra label
        .background(Color.black.opacity(0.85))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(node.color.opacity(0.5), lineWidth: 2))
    }
    
    private func shiftBase(by amount: Double) {
        basePitch += amount
        node.basePitch = Float(basePitch)
        node.updateInternalPitch()
    }
    
    private func reset() {
        basePitch = 0
        finePitch = 0
        node.basePitch = 0
        node.finePitch = 0
        node.updateInternalPitch()
    }
}


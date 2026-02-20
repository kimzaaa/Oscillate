import AVFoundation
import SwiftUI

class ResonanceNode: SynthNode {
    var eqUnit: AVAudioUnitEQ
    var filter: AVAudioUnitEQFilterParameters
    
    init(position: CGPoint) {
        self.eqUnit = AVAudioUnitEQ(numberOfBands: 1)
        self.filter = eqUnit.bands[0]
        self.filter.filterType = .parametric
        self.filter.frequency = 1000.0
        self.filter.bandwidth = 0.5
        self.filter.gain = 0.0
        self.filter.bypass = false
        super.init(name: "Resonance", color: .yellow, icon: "fader.focused", position: position)
        self.avNode = eqUnit
    }
    
    override func content() -> AnyView {
        AnyView(ResonanceNodeView(node: self))
    }
}

struct ResonanceNodeView: View {
    @ObservedObject var node: ResonanceNode
    @State private var freq: Double
    @State private var gain: Double
    @State private var width: Double
    
    init(node: ResonanceNode) {
        self.node = node
        _freq = State(initialValue: Double(node.filter.frequency))
        _gain = State(initialValue: Double(node.filter.gain))
        _width = State(initialValue: Double(node.filter.bandwidth))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("FREQ").font(.system(size: 8, weight: .bold))
                    Spacer()
                    Text("\(Int(freq)) Hz").font(.system(size: 8))
                }
                Slider(value: $freq, in: 20...15000)
                    .accentColor(node.color)
                    .onChange(of: freq) { node.filter.frequency = Float(freq) }
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("PEAK").font(.system(size: 8, weight: .bold))
                    Spacer()
                    Text("\(Int(gain)) dB").font(.system(size: 8))
                }
                Slider(value: $gain, in: 0...24)
                    .accentColor(node.color)
                    .onChange(of: gain) { node.filter.gain = Float(gain) }
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("WIDTH").font(.system(size: 8, weight: .bold))
                    Spacer()
                    Text(String(format: "%.2f oct", width)).font(.system(size: 8))
                }
                Slider(value: $width, in: 0.05...2.0)
                    .accentColor(node.color)
                    .onChange(of: width) { node.filter.bandwidth = Float(width) }
            }
        }
        .padding(12)
        .frame(width: 150, height: 160)
        .background(Color.black.opacity(0.85))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(node.color.opacity(0.5), lineWidth: 2))
    }
}

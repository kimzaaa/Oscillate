import SwiftUI
import AVFoundation

class FilterNode: SynthNode {
    private let eq = AVAudioUnitEQ(numberOfBands: 1)
    
    enum FilterType: String, CaseIterable {
        case lowPass = "LP"
        case highPass = "HP"
        case bandPass = "BP"
        
        var avType: AVAudioUnitEQFilterType {
            switch self {
            case .lowPass: return .lowPass
            case .highPass: return .highPass
            case .bandPass: return .bandPass
            }
        }
    }
    
    @Published var filterType: FilterType = .lowPass {
        didSet {
            updateFilter()
        }
    }
    
    @Published var cutoffFrequency: Float = 1000.0 {
        didSet {
            updateFilter()
        }
    }
    
    @Published var resonance: Float = 0.0 {
        didSet {
            updateFilter()
        }
    }
    
    init(position: CGPoint) {
        super.init(name: "Filter", color: .purple, icon: "waveform.path.ecg", position: position)
        self.avNode = eq
        
        // Initial setup
        updateFilter()
    }
    
    private func updateFilter() {
        let band = eq.bands[0]
        band.filterType = filterType.avType
        band.frequency = cutoffFrequency
        // Map resonance (0-10) to bandwidth. 
        // Bandwidth is in octaves. Lower bandwidth = higher Q (more resonance).
        // Let's map resonance 0 -> 5.0 octaves (wide), 10 -> 0.1 octaves (narrow/resonant).
        let bw = max(0.1, 5.0 - (resonance / 2.0))
        band.bandwidth = bw
        band.bypass = false
    } 
    
    override func content() -> AnyView {
        let typeBinding = Binding<FilterType>(
            get: { self.filterType },
            set: { self.filterType = $0 }
        )
        
        let cutoffBinding = Binding<Double>(
            get: { Double(self.cutoffFrequency) },
            set: { self.cutoffFrequency = Float($0) }
        )
        
        let resBinding = Binding<Double>(
            get: { Double(self.resonance) },
            set: { self.resonance = Float($0) }
        )
        
        return AnyView(
            VStack(spacing: 12) {
                // Filter Curve Visualization
                FilterCurveView(filterType: filterType, cutoff: Double(cutoffFrequency), resonance: Double(resonance))
                    .frame(height: 60)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // TYPE PICKER
                Picker("", selection: typeBinding) {
                    ForEach(FilterType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .scaleEffect(0.8)
                
                // CUTOFF SLIDER
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("CUTOFF")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(cutoffFrequency)) Hz")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Slider(value: cutoffBinding, in: 20...20000)
                        .tint(.purple)
                }
                
                // RESONANCE SLIDER
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("RES")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.1f", resonance))
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Slider(value: resBinding, in: 0...10)
                        .tint(.purple)
                }
            }
            .padding(10)
            .frame(width: 160)
        )
    }
}

struct FilterCurveView: View {
    var filterType: FilterNode.FilterType
    var cutoff: Double
    var resonance: Double
    
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            
            // Map freq 20..20000 to 0..width (Linear for simplicity)
            func xForFreq(_ f: Double) -> Double {
                return (f - 20) / (20000 - 20) * width
            }
            
            let cutoffX = xForFreq(cutoff)
            
            var path = Path()
            
            // Base line is height (bottom)
            path.move(to: CGPoint(x: 0, y: height))
            
            switch filterType {
            case .lowPass:
                // Start high, flat until cutoff
                path.move(to: CGPoint(x: 0, y: height * 0.3)) // Pass band
                
                // Resonance bump before drop
                if resonance > 0 {
                    let bumpHeight = (resonance / 10.0) * (height * 0.2)
                    let cp1 = CGPoint(x: cutoffX - (width * 0.05), y: height * 0.3)
                    let peak = CGPoint(x: cutoffX, y: (height * 0.3) - bumpHeight)
                    let cp2 = CGPoint(x: cutoffX + (width * 0.05), y: height)
                    
                    path.addLine(to: cp1)
                    path.addQuadCurve(to: peak, control: cp1)
                    path.addQuadCurve(to: CGPoint(x: width, y: height), control: cp2)
                } else {
                    path.addLine(to: CGPoint(x: cutoffX, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
                
            case .highPass:
                // Start low, rise at cutoff
                path.move(to: CGPoint(x: 0, y: height))
                
                if resonance > 0 {
                    let bumpHeight = (resonance / 10.0) * (height * 0.2)
                    let cp1 = CGPoint(x: cutoffX - (width * 0.05), y: height)
                    let peak = CGPoint(x: cutoffX, y: (height * 0.3) - bumpHeight)
                    let cp2 = CGPoint(x: cutoffX + (width * 0.05), y: height * 0.3)
                    
                    path.addLine(to: cp1)
                    path.addQuadCurve(to: peak, control: cp1)
                    path.addQuadCurve(to: CGPoint(x: width, y: height * 0.3), control: cp2)
                } else {
                    path.addLine(to: CGPoint(x: cutoffX, y: height))
                    path.addLine(to: CGPoint(x: cutoffX, y: height * 0.3))
                }
                path.addLine(to: CGPoint(x: width, y: height * 0.3))

            case .bandPass:
                // Peak at cutoff
                path.move(to: CGPoint(x: 0, y: height))
                
                let peakHeight = height * 0.2 // Top of peak
                // Resonance narrows the peak
                let widthFactor = max(0.05, 0.4 - (resonance / 30.0)) * width
                
                let startX = max(0, cutoffX - widthFactor)
                let endX = min(width, cutoffX + widthFactor)
                
                path.addLine(to: CGPoint(x: startX, y: height))
                path.addQuadCurve(to: CGPoint(x: cutoffX, y: peakHeight), control: CGPoint(x: startX + (widthFactor/2), y: height))
                path.addQuadCurve(to: CGPoint(x: endX, y: height), control: CGPoint(x: endX - (widthFactor/2), y: height))
                path.addLine(to: CGPoint(x: width, y: height))
            }
            
            context.stroke(path, with: .color(.cyan), lineWidth: 2)
            
            // Fill area under curve
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: width, y: height))
            fillPath.addLine(to: CGPoint(x: 0, y: height))
            fillPath.closeSubpath()
            context.fill(fillPath, with: .linearGradient(
                Gradient(colors: [Color.cyan.opacity(0.4), Color.cyan.opacity(0.0)]),
                startPoint: CGPoint(x: width / 2, y: 0),
                endPoint: CGPoint(x: width / 2, y: height)
            ))
        }
    }
}


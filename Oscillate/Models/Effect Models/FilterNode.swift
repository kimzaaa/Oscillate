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
        didSet { updateFilter() }
    }
    
    @Published var cutoffFrequency: Float = 1000.0 {
        didSet { updateFilter() }
    }
    
    @Published var resonance: Float = 0.0 {
        didSet { updateFilter() }
    }
    
    // Automation
    @Published var isAuto: Bool = false
    @Published var autoSpeed: Float = 0.5 // 0.0 (slow) to 1.0 (fast)
    
    private var automationTimer: Timer?
    private var automationPhase: Double = 0.0 // 0.0 to 1.0 (phase of the sweep)
    private var originalCutoff: Float = 1000.0
    
    init(position: CGPoint) {
        super.init(name: "Filter", color: .purple, icon: "waveform.path.ecg", position: position)
        self.avNode = eq
        updateFilter()
    }
    
    private func updateFilter() {
        let band = eq.bands[0]
        band.filterType = filterType.avType
        band.frequency = cutoffFrequency
        // Map resonance 0..10 -> bandwidth 5.0..0.1 octaves
        let bw = max(0.1, 5.0 - (resonance / 2.0))
        band.bandwidth = bw
        band.bypass = false
    }
    
    // Called when a key is pressed (externally triggered)
    func noteOn() {
        guard isAuto else { return }
        startAutomation()
    }
    
    func noteOff() {
        // Optional: Stop automation or let it finish release?
        // For "0 to 1 to 0", it sounds like a one-shot envelope. 
        // We'll let it run its course or reset. 
        // Typically noteOff might trigger the release phase.
    }
    
    private func startAutomation() {
        automationTimer?.invalidate()
        automationPhase = 0.0
        
        // Speed factor: 0.1s (fastest) to 2.0s (slowest)
        // autoSpeed 1.0 -> 0.1s duration
        // autoSpeed 0.0 -> 2.0s duration
        let duration = 2.0 - (Double(autoSpeed) * 1.9)
        let fps = 60.0
        let step = 1.0 / (duration * fps)
        
        automationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/fps, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            // Phase goes 0 -> 1 -> 0
            // We can map phase 0..1 to a sine wave 0..PI
            
            self.automationPhase += step
            if self.automationPhase >= 1.0 {
                self.automationPhase = 0.0 
                // One shot? User said "0 to 1 to 0 after note pressed". 
                // Implies a single cycle.
                timer.invalidate()
                // Reset to low? Or keep? "to 0" implies back to start.
                self.cutoffFrequency = 20.0 
                return
            }
            
            // Calculate 0..1..0 curve
            // sin(0) = 0, sin(PI/2) = 1, sin(PI) = 0
            let value = sin(self.automationPhase * Double.pi)
            
            // Map 0..1 to frequency range 20..20000 (Exponential feel)
            // Linear modulation of frequency sounds weird, lets do Logarithmic
            // Min 20, Max 20000
            // freq = 20 * (1000)^(value) -> 20 * 1000 = 20000
            
            let minF: Double = 20.0
            let maxF: Double = 20000.0
            // Logarithmic interpolation
            let freq = minF * pow(maxF / minF, value)
            
            DispatchQueue.main.async {
                self.cutoffFrequency = Float(freq)
            }
        }
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
        
        let autoBinding = Binding<Bool>(
            get: { self.isAuto },
            set: { self.isAuto = $0 }
        )
        
        let speedBinding = Binding<Double>(
            get: { Double(self.autoSpeed) },
            set: { self.autoSpeed = Float($0) }
        )
        
        return AnyView(
            VStack(spacing: 8) { // Tighter spacing
                // Filter Curve Visualization
                FilterCurveView(filterType: filterType, cutoff: Double(cutoffFrequency), resonance: Double(resonance))
                    .frame(height: 50) // Reduced height
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
                .scaleEffect(0.75) // Smaller
                
                // CUTOFF SLIDER
                VStack(alignment: .leading, spacing: 0) {
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
                        .scaleEffect(0.8, anchor: .center) // Smaller slider
                        .padding(.vertical, -4) // Reduce slider padding
                }
                
                // RESONANCE SLIDER
                VStack(alignment: .leading, spacing: 0) {
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
                        .scaleEffect(0.8, anchor: .center)
                        .padding(.vertical, -4)
                }
                
                // AUTOMATION
                HStack(spacing: 8) {
                    Toggle("Auto", isOn: autoBinding)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .scaleEffect(0.6)
                        .frame(width: 30)
                    
                    Text("AUTO")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(isAuto ? .white : .gray)
                    
                    Spacer()
                    
                    if isAuto {
                        VStack(spacing: 0) {
                            Text("SPD")
                                .font(.system(size: 6))
                                .foregroundColor(.gray)
                            Slider(value: speedBinding, in: 0...1)
                                .tint(.green)
                                .scaleEffect(0.7)
                                .frame(width: 60)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(10)
            .frame(width: 170) // Overall width constraint
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
            
            // Map freq 20..20000 to 0..width
            func xForFreq(_ f: Double) -> Double {
                return (f - 20) / (20000 - 20) * width
            }
            
            let cutoffX = xForFreq(cutoff)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: height))
            
            switch filterType {
            case .lowPass:
                path.move(to: CGPoint(x: 0, y: height * 0.3)) 
                
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
                path.move(to: CGPoint(x: 0, y: height))
                let peakHeight = height * 0.2
                let widthFactor = max(0.05, 0.4 - (resonance / 30.0)) * width
                let startX = max(0, cutoffX - widthFactor)
                let endX = min(width, cutoffX + widthFactor)
                path.addLine(to: CGPoint(x: startX, y: height))
                path.addQuadCurve(to: CGPoint(x: cutoffX, y: peakHeight), control: CGPoint(x: startX + (widthFactor/2), y: height))
                path.addQuadCurve(to: CGPoint(x: endX, y: height), control: CGPoint(x: endX - (widthFactor/2), y: height))
                path.addLine(to: CGPoint(x: width, y: height))
            }
            
            context.stroke(path, with: .color(.cyan), lineWidth: 2)
            
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


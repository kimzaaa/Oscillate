import SwiftUI
import AVFoundation

class DistortionNode: SynthNode {
    private let distortion = AVAudioUnitDistortion()
    
    // DISTORTION TYPES
    enum DistortType: String, CaseIterable {
        case overdrive = "Tube"// remove this
        case bitcrush = "Crush"
        case cosmic = "Cosmic"
        
        var preset: AVAudioUnitDistortionPreset {
            switch self {
            case .overdrive: return .multiEverythingIsBroken
            case .bitcrush: return .drumsBitBrush
            case .cosmic: return .speechAlienChatter
            }
        }
    }
    
    @Published var selectedType: DistortType = .overdrive {
        didSet {
            distortion.loadFactoryPreset(selectedType.preset)
            // Re-apply drive after switching presets because presets reset values
            distortion.preGain = drive
            distortion.wetDryMix = mix
        }
    }
    
    @Published var drive: Float = 6.0 {
        didSet {
            distortion.preGain = drive
        }
    }
    
    @Published var mix: Float = 50.0 {
        didSet {
            distortion.wetDryMix = mix
        }
    }
    
    init(position: CGPoint) {
        super.init(name: "Distortion", color: .red, icon: "bolt.fill", position: position)
        self.avNode = distortion
        
        // Initial setup
        distortion.loadFactoryPreset(.multiEverythingIsBroken)
        distortion.preGain = drive
        distortion.wetDryMix = mix
    }
    
    override func content() -> AnyView {
        // --- BINDINGS (Old Style) ---
        let typeBinding = Binding<DistortType>(
            get: { self.selectedType },
            set: { self.selectedType = $0 }
        )
        
        let driveBinding = Binding<Double>(
            get: { Double(self.drive) },
            set: { self.drive = Float($0) }
        )
        
        let mixBinding = Binding<Double>(
            get: { Double(self.mix) },
            set: { self.mix = Float($0) }
        )
        
        return AnyView(
            VStack(spacing: 12) {
                // TYPE PICKER
                Picker("", selection: typeBinding) {
                    ForEach(DistortType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .scaleEffect(0.8) // Make it fit better
                
                // DRIVE SLIDER
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("DRIVE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.red)
                        Spacer()
                        Text("\(Int(drive)) dB")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Slider(value: driveBinding, in: 0...20)
                        .tint(.orange)
                }
                
                // MIX SLIDER
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("MIX")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(Int(mix))%")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Slider(value: mixBinding, in: 0...100)
                        .tint(.orange)
                }
            }
                .padding(10)
                .frame(width: 140)
        )
    }
}


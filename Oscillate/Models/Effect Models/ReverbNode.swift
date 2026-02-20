import SwiftUI
import AVFoundation

class ReverbNode: SynthNode {
    
    private let reverbNode = AVAudioUnitReverb()
    
    @Published var mix: Float = 100 {
        didSet {
            reverbNode.wetDryMix = mix
        }
    }
    
    @Published var selectedPreset: ReverbPreset = .largeHall {
        didSet {
            reverbNode.loadFactoryPreset(selectedPreset.avPreset)
        }
    }
    
    enum ReverbPreset: String, CaseIterable {
        case smallRoom = "Small Room"
        case mediumHall = "Medium Hall"
        case largeHall = "Large Hall"
        case cathedral = "Cathedral"
        
        var avPreset: AVAudioUnitReverbPreset {
            switch self {
            case .smallRoom: return .smallRoom
            case .mediumHall: return .mediumHall
            case .largeHall: return .largeHall
            case .cathedral: return .cathedral
            }
        }
    }
    
    init(position: CGPoint) {
        super.init(name: "Reverb", color: .orange, icon: "aqi.medium", position: position)
        self.avNode = reverbNode
        reverbNode.loadFactoryPreset(.largeHall)
        reverbNode.wetDryMix = mix
    }
    
    override func content() -> AnyView {
        let presetBinding = Binding<ReverbPreset>(
            get: { self.selectedPreset },
            set: { self.selectedPreset = $0 }
        )
        
        return AnyView(
            VStack(spacing: 8) {
                Picker("Room", selection: presetBinding) {
                    ForEach(ReverbPreset.allCases, id: \.self) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .frame(height: 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(5)
                
                VStack(spacing: 2) {
                    Text("Mix: \(Int(mix))%")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
                .padding(.horizontal, 10)
        )
    }
}

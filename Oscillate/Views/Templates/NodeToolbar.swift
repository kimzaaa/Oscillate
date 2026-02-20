import SwiftUI

struct NodeToolbar: View {
    // Note: Do NOT use $viewModel when calling functions. 
    // Use the viewModel directly.
    @ObservedObject var viewModel: GridViewModel
    
    let columns = [
        GridItem(.fixed(60), spacing: 10),
        GridItem(.fixed(60), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("LIBRARY")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 5)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ToolbarItem(icon: "waveform.path", label: "OSC", color: .blue) {
                    viewModel.spawnNode(type: "Oscillator")
                }
                
                ToolbarItem(icon: "envelope.fill", label: "ADSR", color: .green) {
                    viewModel.spawnNode(type: "ADSR")
                }
                
                ToolbarItem(icon: "fossil.shell.fill", label: "VERB", color: .orange) {
                    viewModel.spawnNode(type: "Reverb")
                }
                ToolbarItem(icon: "f.cursive", label: "RESO", color: .yellow) { 
                    viewModel.spawnNode(type: "Resonance") 
                }
                ToolbarItem(icon: "bolt", label: "DIST", color: .red) { 
                    viewModel.spawnNode(type: "Distortion") 
                }
                ToolbarItem(icon: "music.note", label: "PITCH", color: .purple) { 
                    viewModel.spawnNode(type: "Pitch" ) 
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.12))
                .shadow(color: .black.opacity(0.5), radius: 10, x: -5, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct ToolbarItem: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(label)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

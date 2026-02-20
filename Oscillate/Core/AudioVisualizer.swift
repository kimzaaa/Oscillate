import SwiftUI
import Accelerate
import AVFoundation

struct AudioVisualizer: View {
    @State private var fftMagnitudes: [CGFloat] = Array(repeating: 0.0, count: 80)
    let labels = ["20Hz", "200Hz", "1kHz", "5kHz", "10kHz"]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("FREQUENCY SPECTRUM")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.cyan.opacity(0.8))
            
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Path { path in
                        for i in 0...6 {
                            let y = CGFloat(i) * 20
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: 300, y: y))
                        }
                    }.stroke(Color.cyan.opacity(0.1), lineWidth: 0.5)
                    
                    EQLineShape(magnitudes: fftMagnitudes)
                        .stroke(
                            LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 300, height: 120)
                }
                .frame(width: 300, height: 120)
                .background(Color.black)
                .clipped()
                
                HStack {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        if label != labels.last { Spacer() }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                .frame(width: 300)
            }
            .padding(8)
            .background(Color.black.opacity(0.9))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .onAppear { setupFFTTap() }
    }
    
    private func setupFFTTap() {
        let mixer = AudioEngine.shared.mainMixer
        let bus = 0
        let fftSize = 1024
        mixer.removeTap(onBus: bus)
        mixer.installTap(onBus: bus, bufferSize: AVAudioFrameCount(fftSize), format: mixer.outputFormat(forBus: bus)) { buffer, _ in
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let magnitudes = performFFT(buffer: channelData, size: fftSize)
            DispatchQueue.main.async { self.fftMagnitudes = magnitudes }
        }
    }
    
    private func performFFT(buffer: UnsafePointer<Float>, size: Int) -> [CGFloat] {
        var real = Array(repeating: Float(0), count: size / 2)
        var imag = Array(repeating: Float(0), count: size / 2)
        let log2n = vDSP_Length(log2(Float(size)))
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        
        let result = real.withUnsafeMutableBufferPointer { realBP in
            imag.withUnsafeMutableBufferPointer { imagBP in
                var splitComplex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                buffer.withMemoryRebound(to: DSPComplex.self, capacity: size / 2) { 
                    vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(size / 2)) 
                }
                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                var magnitudes = Array(repeating: Float(0), count: size / 2)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(size / 2))
                return magnitudes
            }
        }
        vDSP_destroy_fftsetup(fftSetup)
        return result.prefix(80).map { CGFloat(min(sqrt($0) / 10.0, 1.0)) }
    }
}

struct EQLineShape: Shape {
    var magnitudes: [CGFloat]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard magnitudes.count > 1 else { return path }
        let stepX = rect.width / CGFloat(magnitudes.count - 1)
        for i in 0..<magnitudes.count {
            let x = CGFloat(i) * stepX
            let y = rect.height - (magnitudes[i] * rect.height)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}

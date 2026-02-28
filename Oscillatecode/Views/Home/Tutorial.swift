import SwiftUI
import AVKit

enum MediaSource {
    case video(String)
    case image(String)
}

struct Tutorial: View {
    @State private var currentPage = 0
    @State private var navigateToMain = false
    
    let mediaItems: [MediaSource] = [
        .video("move"), 
        .video("zoom"),
        .video("wire"),
        .video("delete"),
        .image("Midi"),
        .image("Keyboard")
    ]
    let labels = [
        "Slide your finger to move",
        "Pinch to zoom",
        "Hold the green node to create a wire",
        "Double tap on wire/node to delete (DO NOT delete the output node)",
        "Press on 'Play Midi' button to play a jingle",
        "Press on the keyboard to play a note"
    ]
    
    var body: some View {
        if navigateToMain {
            Main()
                .navigationBarBackButtonHidden(true)
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    MediaContainer(source: mediaItems[currentPage])
                        .frame(width: 1200, height: 500)
                        .clipped()
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        Text(labels[currentPage])
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                        
                        Button(action: {
                            if currentPage < mediaItems.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                navigateToMain = true
                            }
                        }) {
                            Text(currentPage == mediaItems.count - 1 ? "FINISH" : "NEXT")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
    }
}

struct MediaContainer: View {
    let source: MediaSource
    
    var body: some View {
        switch source {
        case .video(let name):
            LoopingPlayer(fileName: name)
        case .image(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

struct LoopingPlayer: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        
        player.isMuted = true
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.playerLayer?.frame = CGRect(x: 0, y: 0, width: 1200, height: 500)
        
        if context.coordinator.currentFileName != fileName {
            context.coordinator.currentFileName = fileName
            
            guard let path = Bundle.main.path(forResource: fileName, ofType: "mov") else { return }
            let url = URL(fileURLWithPath: path)
            let playerItem = AVPlayerItem(url: url)
            
            NotificationCenter.default.removeObserver(context.coordinator)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
                context.coordinator.player?.seek(to: .zero)
                context.coordinator.player?.play()
            }
            
            context.coordinator.player?.replaceCurrentItem(with: playerItem)
            context.coordinator.player?.play()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var currentFileName: String?
    }
}

import SwiftUI
import AVKit

struct Tutorial: View {
    @State private var currentPage = 0
    @State private var navigateToMain = false
    
    let videoUris = [
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284313/ScreenRecording_02-28-2569_19-57-34_1_wytzkl.mov",
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284552/ScreenRecording_02-28-2569_20-15-04_1_vc4fts.mov",
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284313/ScreenRecording_02-28-2569_19-58-10_1_dyssvs.mov",
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284314/ScreenRecording_02-28-2569_19-58-23_1_y7kug6.mov",
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284314/ScreenRecording_02-28-2569_19-58-34_1_cu2u9h.mov",
        "https://res.cloudinary.com/dpduyofon/video/upload/v1772284315/ScreenRecording_02-28-2569_19-58-47_1_tbluez.mov"
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
                    
                    LoopingPlayer(uri: videoUris[currentPage])
                        .frame(width: 1200, height: 500)
                        .clipped()
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        Text(labels[currentPage])
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                        
                        Button(action: {
                            if currentPage < 5 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                navigateToMain = true
                            }
                        }) {
                            Text(currentPage == 5 ? "FINISH" : "NEXT")
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

struct LoopingPlayer: UIViewRepresentable {
    let uri: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let player = AVPlayer() // Initialize empty
        let playerLayer = AVPlayerLayer(player: player)
        
        player.isMuted = true
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        // Store the player in the coordinator so updateUIView can access it
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the frame
        context.coordinator.playerLayer?.frame = CGRect(x: 0, y: 0, width: 1200, height: 500)
        
        // Check if the URL has changed before reloading
        if context.coordinator.currentUri != uri {
            context.coordinator.currentUri = uri
            
            guard let url = URL(string: uri) else { return }
            let playerItem = AVPlayerItem(url: url)
            
            // Loop the new item
            NotificationCenter.default.removeObserver(context.coordinator, name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
        var currentUri: String?
    }
}


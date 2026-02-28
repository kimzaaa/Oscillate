import SwiftUI
import AVKit
import AVFoundation // Added to control the Silent/Mute switch behavior

struct Intro: View {
    @State private var showLevel1 = false
    // Your Cloudinary URI
    let videoURLString = "https://res.cloudinary.com/dpduyofon/video/upload/v1772201341/m1_1_yu1xol.mp4"
    
    var body: some View {
        ZStack {
            if showLevel1 {
                Level1Main() // Reverted to your original view call
                    .transition(.opacity)
            } else {
                ZStack {
                    if let url = URL(string: videoURLString) {
                        VideoContainerView(url: url) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showLevel1 = true
                            }
                        }
                        .ignoresSafeArea()
                    } else {
                        Color.black
                            .ignoresSafeArea()
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct VideoContainerView: View {
    let url: URL
    var onComplete: () -> Void
    
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                // 1. Configure audio to play even if the physical Silent switch is ON
                setupAudio()
                
                let avPlayer = AVPlayer(url: url)
                self.player = avPlayer
                avPlayer.play()
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: avPlayer.currentItem,
                    queue: .main
                ) { _ in
                    onComplete()
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
    
    // Helper to override system silence
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session error: \(error)")
        }
    }
}


import SwiftUI
import AVKit
import AVFoundation 

struct Intro: View {
    @State private var showLevel1 = false
    
    let videoURLString = "https://res.cloudinary.com/dpduyofon/video/upload/v1772201341/m1_1_yu1xol.mp4"
    
    var body: some View {
        ZStack {
            if showLevel1 {
                Level1Main() 
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
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
    }
}

import SwiftUI
import AVKit
import AVFoundation 

struct Level2Main: View {
    @State private var showLevel1 = false
    
    let videoFileName = "Level2Main"
    let videoFileExtension = "MOV"
    
    var body: some View {
        ZStack {
            if showLevel1 {
                Level2_1Main() 
                    .transition(.opacity)
            } else {
                if let url = Bundle.main.url(forResource: videoFileName, withExtension: videoFileExtension) {
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
                NotificationCenter.default.removeObserver(self)
            }
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
}

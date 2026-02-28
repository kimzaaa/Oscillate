import SwiftUI
import AVKit
import AVFoundation

struct ShowcaseView: View {
    let cards = ShowcaseData.cards
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Color.clear
                    .frame(width: 700, height: 500)
                    .overlay(
                        Image("GALLERY")
                            .resizable()
                            .scaledToFit()
                    )
                    .clipped()
                    .padding(.top, -100)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(cards) { card in
                        ShowcaseCardView(card: card)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct ShowcaseCardView: View {
    let card: ShowcaseCard
    
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let p = player {
                    VideoPlayer(player: p)
                        .frame(height: 180)
                        .onDisappear {
                            p.pause()
                            isPlaying = false
                        }
                } else {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 180)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setupAndTogglePlayer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(card.title)
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    
                    Text(card.difficulty.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(card.difficulty).opacity(0.2))
                        .foregroundColor(difficultyColor(card.difficulty))
                        .cornerRadius(8)
                }
                
                Text(card.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
    
    private func setupAndTogglePlayer() {
        if player == nil {
            guard let url = Bundle.main.url(forResource: card.videoURL, animated: false) ?? 
                    Bundle.main.url(forResource: card.videoURL, withExtension: "mov") else {
                return
            }
            
            let newPlayer = AVPlayer(url: url)
            newPlayer.preventsDisplaySleepDuringVideoPlayback = true
            self.player = newPlayer
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
        }
        
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            try? AVAudioSession.sharedInstance().setActive(true)
            player?.play()
            isPlaying = true
        }
    }
    
    private func difficultyColor(_ level: ShowcaseCard.Difficulty) -> Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        case .expert: return .purple
        }
    }
}

private extension Bundle {
    func url(forResource name: String, animated: Bool) -> URL? {
        return self.url(forResource: name, withExtension: "mov")
    }
}

import SwiftUI
import AVKit

struct ShowcaseView: View {
    let cards = ShowcaseData.cards
    
    // Grid layout for cards
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Sound Gallery")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)
                
                Text("See what you can build in Sandbox Mode.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(cards) { card in
                        ShowcaseCardView(card: card)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Showcase")
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
            // Video Header
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
            
            // Content Body
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
                    .lineLimit(4)
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
            // Try to resolve URL
            var url: URL?
            if card.videoURL.hasPrefix("http") {
                url = URL(string: card.videoURL)
            } else if let localURL = Bundle.main.url(forResource: card.videoURL, withExtension: "mp4") {
                url = localURL
                // Optional: Check other paths like Resources/Lv1 if your videos are nested
            } else if let localURL = Bundle.main.url(forResource: card.videoURL, withExtension: "mp4", subdirectory: "Resources") {
                url = localURL
            }
            
            guard let resolvedURL = url else {
                print("Could not find video: \(card.videoURL)")
                return
            }
            
            player = AVPlayer(url: resolvedURL)
        }
        
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
            
            // Loop functionality
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                player?.seek(to: .zero)
                player?.play()
            }
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

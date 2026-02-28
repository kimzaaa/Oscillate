import SwiftUI
import AVKit

struct Level2Main: View {
    @State private var showLevel1 = false
    
    let videoURLString = "https://res.cloudinary.com/dpduyofon/video/upload/v1772202290/oscil2_rokx6s.mov"
    
    var body: some View {
        ZStack {
            if showLevel1 {
                Level2_1Main()
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

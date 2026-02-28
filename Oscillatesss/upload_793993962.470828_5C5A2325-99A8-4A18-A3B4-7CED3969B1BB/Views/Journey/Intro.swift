import SwiftUI
import AVKit
import AVFoundation 

struct Intro: View {
    @State private var showLevel1 = false
    
    let videoFileName = "Intro"
    let videoFileExtension = "MP4"
    
    var body: some View {
        ZStack {
            if showLevel1 {
                Level1Main() 
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



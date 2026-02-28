import SwiftUI

struct JourneyMain: View {
    @State private var showLevel1 = false
    @State private var showHeadphonesNotice = true
    
    var body: some View {
        @State var isPressed = false
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showHeadphonesNotice {
                VStack(spacing: 24) {
                    Image(systemName: "headphones")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundStyle(.white)
                    
                    Text("USE HEADPHONES FOR BEST EXPERIENCE")
                        .font(.system(size: 10, weight: .medium))
                        .kerning(0.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            showHeadphonesNotice = false
                        }
                    }
                }
            } else if showLevel1 {
                Intro()
                    .transition(.opacity)
            } else {
                VStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showLevel1 = true
                        }
                    }) {
                        Color.clear
                            .frame(width: 220, height: 50)
                            .overlay(
                                Image("BEGIN")
                                    .resizable()
                                    .scaledToFill()
                            )
                            .clipped()
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
        }
    }
}

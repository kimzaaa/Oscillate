import SwiftUI

struct JourneyMain: View {
    @State private var showLevel1 = false

    var body: some View {
        ZStack {
            if showLevel1 {
                Level1Main()
                    .transition(.opacity)
            } else {
                VStack {
                    Text("Journey Mode")
                        .font(.largeTitle)
                        .padding()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLevel1 = true
                        }
                    }) {
                        Text("Start Level 1")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

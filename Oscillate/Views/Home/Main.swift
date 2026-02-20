import SwiftUI

struct Main: View {
    var body: some View {
        NavigationStack{
            VStack {
                NavigationLink("Journey Mode"){
                    JourneyMain()
                }
                .buttonStyle(.borderedProminent)
                NavigationLink("Sandbox Mode"){
                    SandboxMain()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

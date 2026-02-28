import SwiftUI

struct Main: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("OSCILLATE")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 700)
                    .offset(y: -120)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 64) {
                            NavigationLink {
                                JourneyMain()
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                Color.clear
                                    .frame(width: 275, height: 100)
                                    .overlay(Image("JOURNEY").resizable().scaledToFill())
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                ShowcaseView()
                            } label: {
                                Color.clear
                                    .frame(width: 275, height: 100)
                                    .overlay(Image("EXPLORE").resizable().scaledToFill())
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                SandboxMain()
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                Color.clear
                                    .frame(width: 275, height: 100)
                                    .overlay(Image("SANDBOXS").resizable().scaledToFill())
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                        }
                        
                        HStack(spacing: 64) {
                            NavigationLink {
                                Tutorial()
                            } label: {
                                Color.clear
                                    .frame(width: 200, height: 100)
                                    .overlay(Image("TUTORIAL").resizable().scaledToFill())
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                Credit()
                            } label: {
                                Color.clear
                                    .frame(width: 200, height: 100)
                                    .overlay(Image("CREDITS").resizable().scaledToFill())
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 150)
                }
            }
        }
    }
}

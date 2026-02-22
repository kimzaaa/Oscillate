import SwiftUI

struct NodeView: View {
    @ObservedObject var node: SynthNode
    
    var body: some View {
        VStack {
            Text(node.name)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)
            
            Spacer()
            
            node.content()
            
            Spacer()
        }
        .frame(width: 250, height: 250)
        .background(node.color)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

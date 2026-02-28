import SwiftUI

struct Credit: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Development")) {
                    CreditRow(title: "Programming", detail: "Thitiwat Buayam")
                }
                Section(header: Text("Tech Stack")) {
                    CreditRow(title: "Language", detail: "Swift")
                    CreditRow(title: "Media Hosting", detail: "Cloudinary")
                }
                
                Section(header: Text("Project Notes"), footer: Text("Using remote URIs ensures the app remains lightweight and performant.")) {
                    Text("I integrated Cloudinary as a remote host for assets. By fetching URI links, I significantly reduced the total project size.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Credits")
        }
    }
}

// A reusable view for credit lines
struct CreditRow: View {
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(detail)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
}

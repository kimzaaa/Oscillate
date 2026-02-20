import Foundation

struct Wire: Identifiable, Equatable{
    let id = UUID()
    let startNodeID: UUID
    let endNodeID: UUID
}


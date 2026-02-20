import SwiftUI

struct SandboxMain: View {
    @StateObject var viewModel = GridViewModel()
    @State private var movingNodeID: UUID? = nil
    @State private var movingOffset: CGSize = .zero
    
    // REMOVED: canvasOffset, dragTranslation, totalOffset
    // The screen is now static, which fixes the jitter and touch conflicts.
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ZStack {
                    // REMOVED: Background DragGesture
                    
                    WireLayer(
                        viewModel: viewModel,
                        movingNodeID: movingNodeID,
                        movingOffset: movingOffset
                    )
                    
                    ForEach(viewModel.nodes) { node in
                        DraggableNode(
                            node: node,
                            onDragChange: { offset in
                                movingNodeID = node.id
                                movingOffset = offset
                            },
                            onMoveEnd: { finalLocation in
                                viewModel.updateNodePosition(id: node.id, newPosition: finalLocation)
                                movingNodeID = nil
                                movingOffset = .zero
                            },
                            onStartWire: { location in
                                // SIMPLIFIED: No longer need to subtract canvas offset
                                viewModel.startWireDrag(from: node.id, at: location)
                            },
                            onUpdateWire: { location in
                                viewModel.updateWireDrag(to: location)
                            },
                            onEndWire: {
                                viewModel.endWireDrag()
                            }
                        )
                    }
                }
                .coordinateSpace(name: "CanvasSpace")
            }
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    KeyboardView(onNoteOn: { freq in
                        for node in viewModel.nodes {
                            if let osc = node as? OscillatorNode {
                                osc.noteOn(frequency: freq)
                            } else if let adsr = node as? ADSRNode {
                                adsr.noteOn() // ADSR only needs to know a note started, doesn't care about frequency in this simple model
                            }
                        }
                    }, onNoteOff: { freq in
                        for node in viewModel.nodes {
                            if let osc = node as? OscillatorNode {
                                osc.noteOff(frequency: freq)
                            } else if let adsr = node as? ADSRNode {
                                adsr.noteOff()
                            }
                        }
                    })
                    .frame(height: geometry.size.height * 0.2)
                    .padding(.horizontal, 20) // Add horizontal padding to make it narrower overall
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: .infinity, alignment: .bottom) // Align to bottom
            }
            // Removed .allowsHitTesting(false) so keyboard works
            
            HStack(spacing: 0) {
                Spacer()
                NodeToolbar(viewModel: viewModel)
                    .frame(width: 160)
                    .padding(.trailing, 20)
                    .padding(.vertical, 40)
            }
        }
    }
}


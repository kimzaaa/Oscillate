import SwiftUI

struct SandboxMain: View {
    @StateObject var viewModel = GridViewModel()
    @State private var movingNodeID: UUID? = nil
    @State private var movingOffset: CGSize = .zero
    
    // Zoom and Pan State
    @State private var canvasOffset: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0
    // To smooth things or handle state during gesture
    @GestureState private var magnifyBy: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ZStack {
                    WireLayer(
                        viewModel: viewModel,
                        movingNodeID: movingNodeID,
                        movingOffset: movingOffset
                    )
                    
                    ForEach(viewModel.nodes) { node in
                        DraggableNode(
                            node: node,
                            // Pass zoomScale removed
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
                .scaleEffect(zoomScale * magnifyBy)
                .offset(x: canvasOffset.width + dragOffset.width, y: canvasOffset.height + dragOffset.height)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle()) // Make the entire area hit-testable
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            canvasOffset.width += value.translation.width
                            canvasOffset.height += value.translation.height
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .updating($magnifyBy) { currentState, gestureState, _ in
                            gestureState = currentState
                        }
                        .onEnded { value in
                            zoomScale *= value
                        }
                )
            }
            
            GeometryReader { geometry in
            
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


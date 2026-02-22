import SwiftUI

struct SandboxMain: View {
    @StateObject var viewModel = GridViewModel()
    @StateObject var sequencer = MidiSequencer() // Add sequencer
    @State private var showFilePicker = false // File picker state
    
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
            // Background Layer
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            // Grid
            GridBackground(
                gridSize: 50, 
                pan: CGSize(width: canvasOffset.width + dragOffset.width, height: canvasOffset.height + dragOffset.height),
                zoom: zoomScale * magnifyBy
            )
            .edgesIgnoringSafeArea(.all)
            
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
                            },
                            onRemove: {
                                viewModel.removeNode(node.id)
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
                VStack {
                    Spacer()
                    
                    KeyboardView(onNoteOn: { freq in
                        for node in viewModel.nodes {
                            if let osc = node as? OscillatorNode {
                                osc.noteOn(frequency: freq)
                            } else if let adsr = node as? ADSRNode {
                                adsr.noteOn() // ADSR only needs to know a note started
                            } else if let filter = node as? FilterNode {
                                filter.noteOn()
                            }
                        }
                    }, onNoteOff: { freq in
                        for node in viewModel.nodes {
                            if let osc = node as? OscillatorNode {
                                osc.noteOff(frequency: freq)
                            } else if let adsr = node as? ADSRNode {
                                adsr.noteOff()
                            } else if let filter = node as? FilterNode {
                                filter.noteOff()
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
                VStack(spacing: 20) {
                    // MIDI Playback Button
                    Button(action: {
                        if sequencer.currentFile == nil {
                            showFilePicker = true
                        } else {
                            sequencer.togglePlay()
                        }
                    }) {
                        HStack {
                            Image(systemName: sequencer.isPlaying ? "stop.fill" : "play.fill")
                            Text(sequencer.currentFile == nil ? "Load MIDI" : (sequencer.isPlaying ? "Stop" : "Play MIDI"))
                                .font(.caption.bold())
                        }
                        .padding(10)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.midi]) { result in
                        switch result {
                        case .success(let url):
                            // Access security scoped resource
                            if url.startAccessingSecurityScopedResource() {
                                sequencer.load(url: url)
                                // Handle cleanup later if needed, but for now we keep access
                            }
                        case .failure(let error):
                            print("Error picking file: \(error.localizedDescription)")
                        }
                    }
                    
                    if sequencer.currentFile != nil {
                        VStack(spacing: 5) {
                            Text("Speed: \(String(format: "%.1fx", sequencer.playbackSpeed))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $sequencer.playbackSpeed, in: 0.1...3.0)
                                .frame(width: 100)
                                .tint(.blue)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    NodeToolbar(viewModel: viewModel)
                        .frame(width: 160)
                }
                .padding(.trailing, 20)
                .padding(.vertical, 40)
            }
        }
        .onAppear {
             // Connect sequencer to view model
             sequencer.onNoteOn = { freq in
                 viewModel.noteOn(frequency: freq)
             }
             sequencer.onNoteOff = { freq in
                 viewModel.noteOff(frequency: freq)
             }
        }
    }
}


import SwiftUI

struct SynthLevelView: View {
    let config: LevelConfiguration
    
    @StateObject var viewModel = GridViewModel()
    @StateObject var sequencer = MidiSequencer()
    @State private var showFilePicker = false
    
    @State private var movingNodeID: UUID? = nil
    @State private var movingOffset: CGSize = .zero
    
    @State private var canvasOffset: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0
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
                .contentShape(Rectangle()) 
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
            
            // Keyboard Layer
            if config.showKeyboard {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        KeyboardView(onNoteOn: { freq in
                            viewModel.noteOn(frequency: freq)
                        }, onNoteOff: { freq in
                            viewModel.noteOff(frequency: freq)
                        })
                        .frame(height: geometry.size.height * 0.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            
            // UI Overlay Layer
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 20) {
                    
                    if config.showMidi {
                        if let _ = config.midiFilename {
                            // Hardcoded MIDI path
                            Button(action: {
                                sequencer.togglePlay()
                            }) {
                                HStack {
                                    Image(systemName: sequencer.isPlaying ? "stop.fill" : "play.fill")
                                    Text(sequencer.isPlaying ? "Stop" : "Play MIDI")
                                        .font(.caption.bold())
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                            }
                        } else {
                            // Sandbox "Open File" path
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
                                    if url.startAccessingSecurityScopedResource() {
                                        sequencer.load(url: url)
                                    }
                                case .failure(let error):
                                    print("Error picking file: \(error.localizedDescription)")
                                }
                            }
                            
                            // Only show slider if we don't have a fixed speed in config
                            if sequencer.currentFile != nil && config.midiPlaybackSpeed == nil {
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
                        }
                    }
                    
                    Spacer()
                    
                    NodeToolbar(
                        viewModel: viewModel, 
                        availableNodes: config.availableNodes
                    )
                    .frame(width: 160)
                }
                .padding(.trailing, 20)
                .padding(.vertical, 40)
            }
        }
        .onAppear {
             viewModel.setupLevel(config: config)
             
             // Setup Sequencer
             sequencer.onNoteOn = { freq in
                 viewModel.noteOn(frequency: freq)
             }
             sequencer.onNoteOff = { freq in
                 viewModel.noteOff(frequency: freq)
             }
             
             if let filename = config.midiFilename {
                 if let url = Bundle.main.url(forResource: filename, withExtension: "mid") ?? Bundle.main.url(forResource: filename, withExtension: "midi") {
                     sequencer.load(url: url)
                 } else {
                     print("Could not find MIDI file: \(filename)")
                 }
             }
             
             if let speed = config.midiPlaybackSpeed {
                 sequencer.playbackSpeed = speed
             }
        }
    }
}

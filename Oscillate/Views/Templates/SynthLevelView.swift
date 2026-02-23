import SwiftUI
import AVFoundation

class DialogueController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?
    
    func play(filename: String) {
        
        // Debugging: Print all MP3s found in the bundle to see where they are
        if let resources = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) {
            print("--- Resources Found ---")
            for res in resources {
                print("Found MP3: \(res.lastPathComponent) at \(res.relativePath)")
            }
            print("--- End Resources ---")
        } else {
             print("--- No MP3s found in Bundle ---")
        }

        // Try finding file in root or subdirectories
        var fileURL: URL?
        
        print("--- Finding audio file: \(filename) ---")

        // Try finding file in root or subdirectories
        var fileURL: URL?
        
        // Check root first
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp3") {
            fileURL = url
        }
        // Check in Lv1 (common if Resources is a group but Lv1 is a folder ref, or just flattened differently)
        else if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "Lv1") {
             fileURL = url
        }
        // Check in Resources/Lv1
        else if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "Resources/Lv1") {
             fileURL = url
        }
        // Check in Resources
        else if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "Resources") {
             fileURL = url
        }
        // Check in resources/lv (user specified path, might be lowercase in bundle)
        else if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "resources/lv") {
             fileURL = url
        }
        
        // Final fallback: Search ALL mp3s in bundle recursively to find filename match
        if fileURL == nil {
             if let enumerator = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil) {
                 for case let fileURLCandidate as URL in enumerator {
                     if fileURLCandidate.lastPathComponent.lowercased() == "\(filename.lowercased()).mp3" {
                         print("Found by recursive search: \(fileURLCandidate)")
                         fileURL = fileURLCandidate
                         break
                     }
                 }
             }
        }

        guard let url = fileURL else {
            print("Could not find audio file: \(filename)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

struct SynthLevelView: View {
    let config: LevelConfiguration
    
    @StateObject var viewModel = GridViewModel()
    @StateObject var sequencer = MidiSequencer()
    @StateObject private var dialogueController = DialogueController()
    
    @State private var showFilePicker = false
    @State private var showHintAlert = false
    
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
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    
                    // Hint Button (Top Right)
                    if config.hintText != nil {
                        Button(action: {
                            showHintAlert = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding([.top, .trailing], 20)
                        .alert(isPresented: $showHintAlert) {
                            Alert(title: Text("Hint"), message: Text(config.hintText ?? ""), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    // Toolbar (Middle Right)
                    VStack {
                        Spacer()
                        NodeToolbar(
                            viewModel: viewModel, 
                            availableNodes: config.availableNodes
                        )
                        .frame(width: 80) // Adjust width as needed for vertical toolbar or keeps horizontal?
                        // Assuming NodeToolbar is vertical? Looking at context it's likely a list or vertical stack based on previous context.
                        // Wait, previous context had `.frame(width: 160)` and was in a VStack.
                        // Assuming NodeToolbar handles its orientation or is designed vertically.
                        // If it's horizontal, I might need to rotate it?
                        // Let's assume it's vertical for "toolbar on the right".
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    
                    
                    // MIDI Controls (Top Right, slightly below Hint or to left?)
                    // Placing it Top Left or Top Center to avoid cluttering Top Right?
                    // User didn't specify MIDI location, just toolbar.
                    // I'll put MIDI controls top-center for now.
                    if config.showMidi {
                        HStack {
                           Spacer()
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
                                HStack {
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
                                        .background(
                                            (sequencer.currentFile == nil && config.midiFilename == nil) ? Color.gray : Color.blue.opacity(0.8)
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 5)
                                    }
                                    .disabled(sequencer.currentFile == nil && config.midiFilename == nil && !showFilePicker) 
                                    // Wait, logic: if no file loaded, button should be "Load MIDI" (active)
                                    // If file loaded, button is Play/Stop.
                                    // User said "if play midi is nil, make the play midi button not active".
                                    // This likely means if no file is ready to play, don't show Play.
                                    // But we have "Load".
                                    
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
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
            }
            // Dialogue Overlay
            if dialogueController.isPlaying {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        // Placeholder Square
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 200, height: 200)
                            .overlay(Text("Dialogue Placeholder").foregroundColor(.white))
                            .shadow(radius: 10)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                dialogueController.stop()
                            }
                        }) {
                            Text("Skip Dialogue")
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                        .padding(.bottom, 50)
                    }
                }
                .transition(.opacity)
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
             
             if let dialogueFile = config.playDialogueOnStart {
                 dialogueController.play(filename: dialogueFile)
             }
        }
    }
}

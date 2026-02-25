import SwiftUI
import AVFoundation
import AVKit

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

struct LoopingVideo: View {
    let fileName: String
    let width: CGFloat
    let height: CGFloat
    
    @State private var queuePlayer: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        Group {
            if let p = queuePlayer {
                VideoPlayer(player: p)
                    .frame(width: width, height: height)
                    .onAppear { p.play() }
                    .onDisappear { p.pause() }
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: width, height: height)
                    .overlay(ProgressView())
            }
        }
        .onAppear { setupPlayer() }
    }
    
    private func setupPlayer() {
        if queuePlayer != nil { return }
        
        var fileURL: URL?
        
        // Check if fileName is a remote URL
        if let url = URL(string: fileName), url.scheme == "http" || url.scheme == "https" {
            fileURL = url
        } else {
            // Basic bundle search
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") {
                fileURL = url
            }
            else if let url = Bundle.main.url(forResource: fileName, withExtension: "mp4", subdirectory: "Lv1") {
                 fileURL = url
            }
            else if let url = Bundle.main.url(forResource: fileName, withExtension: "mp4", subdirectory: "Resources/Lv1") {
                 fileURL = url
            }
            else if let url = Bundle.main.url(forResource: fileName, withExtension: "mp4", subdirectory: "Resources") {
                 fileURL = url
            }
            else {
                 // Recursive search fallback
                 if let enumerator = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil) {
                     for case let file as URL in enumerator {
                         if file.lastPathComponent.lowercased() == "\(fileName.lowercased()).mp4" {
                             fileURL = file
                             break
                         }
                     }
                 }
            }
        }
        
        guard let url = fileURL else {
            print("Could not find video file: \(fileName)")
            return
        }
        
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        self.playerLooper = AVPlayerLooper(player: player, templateItem: item)
        self.queuePlayer = player
        player.play()
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
    
    // Level Completion State
    @State private var isLevelComplete = false
    @State private var showSuccessOverlay = false
    @State private var hasPlayedNote = false
    @State private var showFinalOverlay = false // New state for second step of note-input levels
    
    // Timer for checking conditions
    let checkTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
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
                            hasPlayedNote = true // Mark as played
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
                        if let videoFile = config.playVideoOnStart, let size = config.videoSize {
                            LoopingVideo(fileName: videoFile, width: size.width, height: size.height)
                                .shadow(radius: 10)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 200, height: 200)
                                .overlay(Text("Dialogue Placeholder").foregroundColor(.white))
                                .shadow(radius: 10)
                        }
                        
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
            
            // Success / Next Level Overlay
            if showSuccessOverlay {
                if config.requireNoteInput && !showFinalOverlay {
                    // Non-blocking UI for levels where you need to keep playing
                    VStack {
                        HStack {
                            Spacer()
                            
                            // "Next Level" button that triggers the overlay
                            Button(action: {
                                withAnimation {
                                    showFinalOverlay = true // Show the blocking overlay now
                                }
                            }) {
                                HStack {
                                    Text("Next Level")
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(30)
                                .shadow(radius: 5)
                            }
                            .padding(.top, 50)
                            .padding(.trailing, 20)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.all)
                } else {
                    // Blocking Overlay (Used for Puzzle levels OR Note-levels after button press)
                    VStack(spacing: 20) {
                        Text("LEVEL COMPLETE")
                            .font(.largeTitle.bold())
                            .foregroundColor(.green)
                            .shadow(radius: 5)
                        
                        if let msg = config.successMessage {
                            Text(msg)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                        }
                        
                        // Actual Navigation Link
                        if let nextLevel = config.nextLevelViewName {
                            NavigationLink(destination: destinationView(for: nextLevel)) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8)) // Darker background for final overlay
                    .transition(.opacity)
                    .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onReceive(checkTimer) { _ in
            checkGoals()
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

    // MARK: - Navigation Helper
    @ViewBuilder
    func destinationView(for name: String) -> some View {
        if name == "Level1_1" {
            Level1_1Main()
        } else if name == "Level1_2" {
            // Placeholder if you have it
            EmptyView()
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Goal Checking Logic
    func checkGoals() {
        guard !isLevelComplete else { return }
        
        // If there are no goals, do nothing (Sandbox mode)
        if config.requiredConnections.isEmpty && config.requiredSettings.isEmpty {
            return
        }
        
        // 0. Check Interaction Goals (Have they played a note?)
        if config.requireNoteInput && !hasPlayedNote {
             return
        }
        
        var availableWires = viewModel.wires
        
        for goal in config.requiredConnections {
            if let index = availableWires.firstIndex(where: { wire in
                let startNode = viewModel.nodes.first(where: { $0.id == wire.startNodeID })
                let endNode = viewModel.nodes.first(where: { $0.id == wire.endNodeID })
                
                guard let s = startNode, let e = endNode else { return false }
                
                let sType = String(describing: type(of: s)).replacingOccurrences(of: "Node", with: "")
                let eType = String(describing: type(of: e)).replacingOccurrences(of: "Node", with: "")

                return sType == goal.fromType && eType == goal.toType
            }) {
                availableWires.remove(at: index)
            } else {
                return
            }
        }
        
        for goal in config.requiredSettings {
            let nodes = viewModel.nodes.filter { node in
                let typeName = String(describing: type(of: node)).replacingOccurrences(of: "Node", with: "")
                return typeName == goal.nodeType
            }
            
            let matchFound = nodes.contains { node in
                checkSetting(node: node, setting: goal.settingName, target: goal.targetValue, tolerance: goal.tolerance)
            }
            
            if !matchFound {
                return
            }
        }
        
        withAnimation {
            isLevelComplete = true
            showSuccessOverlay = true
        }
    }
    
    func checkSetting(node: SynthNode, setting: String, target: Double, tolerance: Double?) -> Bool {
        if let oscillator = node as? OscillatorNode {
            // Check Oscillator Settings
        }
        
        if let filter = node as? FilterNode {
            if setting == "cutoffFrequency" {
                let val = Double(filter.cutoffFrequency)
                if let tol = tolerance {
                    return abs(val - target) <= tol
                }
                return val == target
            }
        }
        
        // Default to true if setting can't be checked (or fail?)
        // To be safe, let's fail if we don't know the setting
        return true 
    }
}

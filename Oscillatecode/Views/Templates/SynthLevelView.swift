import SwiftUI
import AVFoundation
import AVKit

class DialogueController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?
    
    static func resolveAudioURL(filename: String) -> URL? {
        return Bundle.main.url(forResource: filename, withExtension: "mp3")
    }
    
    func play(filename: String) {
        let fileURL = Self.resolveAudioURL(filename: filename)
        guard let url = fileURL else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
        } catch {
            print(error.localizedDescription)
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
    
    var body: some View {
        Image(fileName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}

struct SynthLevelView: View {
    let config: LevelConfig
    
    @StateObject var viewModel = GridViewModel()
    @StateObject var sequencer = MidiSequencer()
    @StateObject private var dialogueController = DialogueController()
    
    @State private var showFilePicker = false
    @State private var showHintAlert = false
    @State private var hintAudioPlayer: AVAudioPlayer?
    
    @State private var movingNodeID: UUID? = nil
    @State private var movingOffset: CGSize = .zero
    
    @State private var canvasOffset: CGSize = .zero
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var magnifyBy: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    
    @State private var isLevelComplete = false
    @State private var showSuccessOverlay = false
    @State private var hasPlayedNote = false
    @State private var showFinalOverlay = false 
    
    let checkTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
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
                                if !(node is OutputNode) {
                                    viewModel.removeNode(node.id)
                                }
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
            
            if config.showKeyboard {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        KeyboardView(onNoteOn: { freq in
                            viewModel.noteOn(frequency: freq)
                            hasPlayedNote = true 
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
            
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
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
                            if let hintAudio = config.hintAudioFilename {
                                return Alert(
                                    title: Text("Hint"),
                                    message: Text(config.hintText ?? ""),
                                    primaryButton: .default(Text("Play Audio")) {
                                        playHintAudio(filename: hintAudio)
                                    },
                                    secondaryButton: .default(Text("OK"))
                                )
                            } else {
                                return Alert(
                                    title: Text("Hint"),
                                    message: Text(config.hintText ?? ""),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        NodeToolbar(
                            viewModel: viewModel, 
                            availableNodes: config.availableNodes
                        )
                        .frame(width: 120) 
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    
                    if config.showMidi {
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                if let _ = config.midiFilename {
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
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                                
                                if showSuccessOverlay && config.requireNoteInput && !showFinalOverlay {
                                    Button(action: {
                                        withAnimation {
                                            showFinalOverlay = true
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
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
            }
            
            if dialogueController.isPlaying {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        if let imageFile = config.playVideoOnStart, let size = config.videoSize {
                            LoopingVideo(fileName: imageFile, width: size.width, height: size.height)
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
            
            if showSuccessOverlay {
                if config.requireNoteInput && !showFinalOverlay {
                    if !config.showMidi {
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        showFinalOverlay = true 
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
                                .transition(.move(edge: .top).combined(with: .opacity))
                                Spacer()
                            }
                            Spacer()
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                } else {
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
                    .background(Color.black.opacity(0.8)) 
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
            sequencer.onNoteOn = { freq in
                viewModel.noteOn(frequency: freq)
            }
            sequencer.onNoteOff = { freq in
                viewModel.noteOff(frequency: freq)
            }
            if let filename = config.midiFilename {
                if let url = Bundle.main.url(forResource: filename, withExtension: "mid") ?? Bundle.main.url(forResource: filename, withExtension: "midi") {
                    sequencer.load(url: url)
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
    
    func playHintAudio(filename: String) {
        guard let url = DialogueController.resolveAudioURL(filename: filename) else { return }
        do {
            hintAudioPlayer = try AVAudioPlayer(contentsOf: url)
            hintAudioPlayer?.prepareToPlay()
            hintAudioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func destinationView(for name: String) -> some View {
        switch name {
        case "Level1_1": Level1_1Main().navigationBarBackButtonHidden(true)
        case "Level1_2": Level1_2Main().navigationBarBackButtonHidden(true)
        case "Level1_3": Level1_3Main().navigationBarBackButtonHidden(true)
        case "Level2": Level2Main().navigationBarBackButtonHidden(true)
        case "Level2_1": Level2_1Main().navigationBarBackButtonHidden(true)
        case "Level2_2": Level2_2Main().navigationBarBackButtonHidden(true)
        case "Level2_3": Level2_3Main().navigationBarBackButtonHidden(true)
        case "Level3_1": Level3_1Main().navigationBarBackButtonHidden(true)
        case "Level3_2": Level3_2Main().navigationBarBackButtonHidden(true)
        case "Level4_1": Level4_1Main().navigationBarBackButtonHidden(true)
        case "Level4_2": Level4_2Main().navigationBarBackButtonHidden(true)
        case "Level5_1": Level5_1Main().navigationBarBackButtonHidden(true)
        case "Level5_2": Level5_2Main().navigationBarBackButtonHidden(true)
        case "Level5_3": Level5_3Main().navigationBarBackButtonHidden(true)
        case "Sandbox": SandboxMain().navigationBarBackButtonHidden(true)
        default: EmptyView()
        }
    }
    
    func checkGoals() {
        guard !isLevelComplete else { return }
        if config.requiredConnections.isEmpty && config.requiredSettings.isEmpty { return }
        if config.requireNoteInput && !hasPlayedNote { return }
        var availableWires = viewModel.wires
        for goal in config.requiredConnections {
            if let index = availableWires.firstIndex(where: { wire in
                let startNode = viewModel.nodes.first(where: { $0.id == wire.startNodeID })
                let endNode = viewModel.nodes.first(where: { $0.id == wire.endNodeID })
                guard let s = startNode, let e = endNode else { return false }
                var sType = String(describing: type(of: s)).replacingOccurrences(of: "Node", with: "")
                var eType = String(describing: type(of: e)).replacingOccurrences(of: "Node", with: "")
                if sType == "PitchPan" { sType = "Pitch" }
                if eType == "PitchPan" { eType = "Pitch" }
                return sType == goal.fromType && eType == goal.toType
            }) {
                availableWires.remove(at: index)
            } else {
                return
            }
        }
        for goal in config.requiredSettings {
            let nodes = viewModel.nodes.filter { node in
                var typeName = String(describing: type(of: node)).replacingOccurrences(of: "Node", with: "")
                if typeName == "PitchPan" { typeName = "Pitch" }
                return typeName == goal.nodeType
            }
            let matchFound = nodes.contains { node in
                checkSetting(node: node, setting: goal.settingName, target: goal.targetValue, tolerance: goal.tolerance)
            }
            if !matchFound { return }
        }
        withAnimation {
            isLevelComplete = true
            showSuccessOverlay = true
        }
    }
    
    func checkSetting(node: SynthNode, setting: String, target: Double, tolerance: Double?) -> Bool {
        if let oscillator = node as? OscillatorNode {
            if setting == "waveform" {
                let current: Double
                switch oscillator.waveform {
                case .sine: current = 0.0
                case .square: current = 1.0
                case .triangle: current = 2.0
                case .saw: current = 3.0
                }
                return current == target
            }
            if setting == "volume" {
                let vol = Double(oscillator.volume)
                if let tol = tolerance { return abs(vol - target) <= tol }
                return vol == target
            }
        }
        if let filter = node as? FilterNode {
            if setting == "cutoffFrequency" {
                let val = Double(filter.cutoffFrequency)
                if let tol = tolerance { return abs(val - target) <= tol }
                return val == target
            }
        }
        if let adsr = node as? ADSRNode {
            let val: Double
            switch setting {
            case "attack": val = Double(adsr.attack)
            case "decay": val = Double(adsr.decay)
            case "sustain": val = Double(adsr.sustain)
            case "release": val = Double(adsr.release)
            default: return false
            }
            if let tol = tolerance { return abs(val - target) <= tol }
            return val == target
        }
        if let pitchNode = node as? PitchPanNode {
            let val: Double
            switch setting {
            case "basePitch": val = Double(pitchNode.basePitch)
            case "finePitch": val = Double(pitchNode.finePitch)
            case "pitch": val = Double(pitchNode.basePitch + pitchNode.finePitch)
            default: return false
            }
            if let tol = tolerance { return abs(val - target) <= tol }
            return val == target
        }
        return true 
    }
}

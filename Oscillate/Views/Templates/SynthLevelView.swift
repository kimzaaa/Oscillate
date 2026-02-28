import SwiftUI
import AVFoundation
import AVKit

class DialogueController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var avPlayer: AVAudioPlayer?
    
    func tryFindAudio(named name: String) -> URL? {
        // Quick check common paths
        let paths = ["Resources/Lv1", "Resources"]
        for p in paths {
            if let u = Bundle.main.url(forResource:name, withExtension:"mp3", subdirectory:p) {
                return u
            }
        }
        return Bundle.main.url(forResource:name, withExtension:"mp3")
    }
    
    func play(filename fn: String) {
        guard let u = tryFindAudio(named: fn) else { return }
        
        do {
            avPlayer = try AVAudioPlayer(contentsOf: u)
            avPlayer?.delegate = self
            avPlayer?.prepareToPlay()
            avPlayer?.play()
            isPlaying = true
        } catch {}
    }
    
    func stop() {
        avPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ p: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.isPlaying = false }
    }
}

struct LoopingVideo: View {
    let fileName: String
    let w: CGFloat
    let h: CGFloat
    
    @State private var qPlayer: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    
    var body: some View {
        Group {
            if let p = qPlayer {
                VideoPlayer(player: p)
                    .frame(width: w, height: h)
                    .onAppear { p.play() }
                    .onDisappear { p.pause() }
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: w, height: h)
                    .overlay(ProgressView())
            }
        }
        .onAppear { initVideo() }
    }
    
    private func initVideo() {
        if qPlayer != nil { return }
        
        var u: URL?
        
        if let url = URL(string: fileName), url.scheme?.hasPrefix("http") == true {
             u = url
        } else {
            let paths = ["Lv1", "Resources/Lv1", "Resources"]
            u = Bundle.main.url(forResource:fileName, withExtension:"mp4")
            if u == nil {
                for p in paths {
                    if let found = Bundle.main.url(forResource:fileName, withExtension:"mp4", subdirectory:p) {
                        u = found
                        break
                    }
                }
            }
        }
        
        guard let finalURL = u else { return }
        
        let item = AVPlayerItem(url: finalURL)
        let p = AVQueuePlayer(playerItem: item)
        self.looper = AVPlayerLooper(player: p, templateItem: item)
        self.qPlayer = p
        p.play()
    }
}

struct SynthLevelView: View {
    let config: LevelConfig
    
    @StateObject var vm = GridViewModel()
    @StateObject var seq = MidiSequencer()
    @StateObject private var dialogue = DialogueController()
    
    @State private var showPicker = false
    @State private var showHint = false
    @State private var hintPlayer: AVAudioPlayer?
    
    @State private var mNode: UUID? = nil
    @State private var mOffset: CGSize = .zero
    
    @State private var pan: CGSize = .zero
    @State private var zoom: CGFloat = 1.0
    @GestureState private var mag: CGFloat = 1.0
    @GestureState private var drag: CGSize = .zero
    
    @State private var done = false
    @State private var success = false
    @State private var noteHit = false
    @State private var showFinal = false 
    
    let tmr = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            GridBackground(
                gridSize: 50, 
                pan: CGSize(width: pan.width+drag.width, height: pan.height+drag.height),
                zoom: zoom*mag
            )
            .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                ZStack {
                    WireLayer(
                        viewModel: vm,
                        movingNodeID: mNode,
                        movingOffset: mOffset
                    )
                    
                    ForEach(vm.nodes) { n in
                        DraggableNode(
                            node: n,
                            onDragChange: { off in
                                mNode = n.id
                                mOffset = off
                            },
                            onMoveEnd: { loc in
                                vm.updateNodePosition(id: n.id, newPosition: loc)
                                mNode = nil
                                mOffset = .zero
                            },
                            onStartWire: { loc in
                                vm.startWireDrag(from: n.id, at: loc)
                            },
                            onUpdateWire: { loc in
                                vm.updateWireDrag(to: loc)
                            },
                            onEndWire: {
                                vm.endWireDrag()
                            },
                            onRemove: {
                                vm.removeNode(n.id)
                            }
                        )
                    }
                }
                .coordinateSpace(name: "CanvasSpace")
                .scaleEffect(zoom * mag)
                .offset(x: pan.width + drag.width, y: pan.height + drag.height)
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle()) 
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .updating($drag) { val, s, _ in
                            s = val.translation
                        }
                        .onEnded { val in
                            pan.width += val.translation.width
                            pan.height += val.translation.height
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .updating($mag) { s, g, _ in
                            g = s
                        }
                        .onEnded { val in
                            zoom *= val
                        }
                )
            }
            
            if config.showKeyboard {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        
                        KeyboardView(onNoteOn: { freq in
                            vm.noteOn(frequency:freq)
                            noteHit = true 
                        }, onNoteOff: { freq in
                            vm.noteOff(frequency:freq)
                        })
                        .frame(height: geo.size.height*0.2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            
            GeometryReader {geo in
                ZStack(alignment:.topTrailing) {
                    
                    if config.hintText != nil {
                        Button(action: {
                            showHint = true
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
                        .alert(isPresented: $showHint) {
                            if let hAudio = config.hintAudioFilename {
                                return Alert(
                                    title: Text("Hint"),
                                    message: Text(config.hintText ?? ""),
                                    primaryButton: .default(Text("Play Audio")) {
                                        playHint(file: hAudio)
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
                            viewModel: vm, 
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
                                        seq.togglePlay()
                                    }) {
                                        HStack {
                                            Image(systemName: seq.isPlaying ? "stop.fill" : "play.fill")
                                            Text(seq.isPlaying ? "Stop" : "Play MIDI")
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
                                            if seq.currentFile == nil {
                                                showPicker = true
                                            } else {
                                                seq.togglePlay()
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: seq.isPlaying ? "stop.fill" : "play.fill")
                                                Text(seq.currentFile == nil ? "Load MIDI" : (seq.isPlaying ? "Stop" : "Play MIDI"))
                                                    .font(.caption.bold())
                                            }
                                            .padding(10)
                                            .background(
                                                (seq.currentFile == nil && config.midiFilename == nil) ? Color.gray : Color.blue.opacity(0.8)
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                            .shadow(radius: 5)
                                        }
                                        .disabled(seq.currentFile == nil && config.midiFilename == nil && !showPicker)
                                        
                                        if seq.currentFile != nil && config.midiPlaybackSpeed == nil {
                                            VStack(spacing: 5) {
                                                Text("Speed: \(String(format: "%.1fx", seq.playbackSpeed))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Slider(value: $seq.playbackSpeed, in: 0.1...3.0)
                                                    .frame(width: 100)
                                                    .tint(.blue)
                                            }
                                            .padding(8)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .fileImporter(isPresented: $showPicker, allowedContentTypes: [.midi]) { res in
                                        switch res {
                                        case .success(let u):
                                            if u.startAccessingSecurityScopedResource() {
                                                seq.load(url: u)
                                            }
                                        case .failure:
                                            break
                                        }
                                    }
                                }
                                
                                if success && config.requireNoteInput && !showFinal {
                                    Button(action: {
                                        withAnimation {
                                            showFinal = true
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
            
            if dialogue.isPlaying {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        if let v = config.playVideoOnStart, let s = config.videoSize {
                            LoopingVideo(fileName: v, w: s.width, h: s.height)
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
                                dialogue.stop()
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
            
            if success {
                if config.requireNoteInput && !showFinal {
                    
                    if !config.showMidi {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showFinal = true 
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
                        
                        if let next = config.nextLevelViewName {
                            NavigationLink(destination: destinationView(for: next)) {
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
        .onReceive(tmr) { _ in
            attemptGoals()
        }
        .onAppear {
            vm.setupLevel(config: config)
            
            seq.onNoteOn = { freq in
                vm.noteOn(frequency: freq)
            }
            seq.onNoteOff = { freq in
                vm.noteOff(frequency: freq)
            }
            
            if let fn = config.midiFilename {
                if let u = Bundle.main.url(forResource: fn, withExtension: "mid") ?? Bundle.main.url(forResource: fn, withExtension: "midi") {
                    seq.load(url: u)
                }
            }
            
            if let s = config.midiPlaybackSpeed {
                seq.playbackSpeed = s
            }
            
            if let dFile = config.playDialogueOnStart {
                dialogue.play(filename: dFile)
            }
        }
    }
    
    func playHint(file: String) {
        guard let u = DialogueController().tryFindAudio(named: file) else { return }
        
        do {
            hintPlayer = try AVAudioPlayer(contentsOf: u)
            hintPlayer?.prepareToPlay()
            hintPlayer?.play()
        } catch {}
    }
    
    @ViewBuilder
    func destinationView(for name: String) -> some View {
        if name == "Level1_1" {
            Level1_1Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level1_2" {
            Level1_2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level1_3"{
            Level1_3Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level2"{
            Level2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level2_1"{
            Level2_1Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level2_2"{
            Level2_2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level2_3" {
            Level2_3Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level3_1"{
            Level3_1Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level3_2" {
            Level3_2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level4_1" {
            Level4_1Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level4_2" {
            Level4_2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level5_1" {
            Level5_1Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level5_2" {
            Level5_2Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Level5_3" {
            Level5_3Main()
                .navigationBarBackButtonHidden(true)
        } else if name == "Sandbox"{
            SandboxMain()
                .navigationBarBackButtonHidden(true)
        }
        else {
            EmptyView()
        }
    }
    
    func checkGoals() {
        guard !isLevelComplete else { return }
        
        if config.requiredConnections.isEmpty && config.requiredSettings.isEmpty {
            return
        }
        
        iattemptGoals() {
        guard !done else { return }
        
        // quick check requirements
        let needsConn = !config.requiredConnections.isEmpty
        let needsSet = !config.requiredSettings.isEmpty
        
        if !needsConn && !needsSet { return }
        if config.requireNoteInput && !noteHit { return }
        
        if needsConn && !checkConnections() { return }
        if needsSet && !checkSettings() { return }
        
        completeLevel()
    }
    
    func checkConnections() -> Bool {
        var wires = vm.wires
        for g in config.requiredConnections {
            if let idx = wires.firstIndex(where: {
                matchWire($0, req: g)
            }) {
                wires.remove(at: idx)
            } else {
                return false
            }
        }
        return true
    }
    
    func matchWire(_ w: Wire, req: LevelConnectionGoal) -> Bool {
        guard let s = vm.nodes.first(where: { $0.id == w.startNodeID }),
              let e = vm.nodes.first(where: { $0.id == w.endNodeID }) else { return false }
        
        let sT = cleanType(s)
        let eT = cleanType(e)
        
        return sT == req.fromType && eT == req.toType
    }
    
    func cleanType(_ n: SynthNode) -> String {
        var t = String(describing: type(of: n)).replacingOccurrences(of: "Node", with: "")
        if t == "PitchPan" { return "Pitch" }
        return t
    }
    
    func checkSettings() -> Bool {
        for g in config.requiredSettings {
            let candidates = vm.nodes.filter { cleanType($0) == g.nodeType }
            let ok = candidates.contains { n in
                checkNode(n, key: g.settingName, target: g.targetValue, tol: g.tolerance)
            }
            if !ok { return false }
        }
        return true
    }
    
    func completeLevel() {
        withAnimation {
            done = true
            success = true
        }
    }
    
    func checkNode(_ n: SynthNode, key: String, target: Double, tol: Double?) -> Bool {
        if let osc = n as? OscillatorNode {
            if key == "waveform" {
                let v: Double
                switch osc.waveform {
                case .sine: v = 0.0
                case .square: v = 1.0
                case .triangle: v = 2.0
                case .saw: v = 3.0
                }
                return v == target
            }
            if key == "volume" {
                let v = Double(osc.volume)
                if let t = tol { return abs(v-target) <= t }
                return v == target
            }
        }
        
        if let f = n as? FilterNode {
            if key == "cutoffFrequency" {
                let v = Double(f.cutoffFrequency)
                if let t = tol { return abs(v-target) <= t }
                return v == target
            }
        }
        
        if let a = n as? ADSRNode {
            var v: Double = 0
            if key == "attack" { v = Double(a.attack) }
            else if key == "decay" { v = Double(a.decay) }
            else if key == "sustain" { v = Double(a.sustain) }
            else if key == "release" { v = Double(a.release) }
            else { return false }
            
            if let t = tol { return abs(v - target) <= t }
            return v == target
        }
        
        if let p = n as? PitchPanNode {
            var v: Double = 0
            if key == "basePitch" { v = Double(p.basePitch) }
            else if key == "finePitch" { v = Double(p.finePitch) }
            else if key == "pitch" { v = Double(p.basePitch + p.finePitch) }
            else { return false }
            
            if let t = tol { return abs(v - target) <= t }
            return v
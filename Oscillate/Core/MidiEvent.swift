import Foundation

struct MidiEvent {
    let timestamp: Double // in seconds
    let type: EventType
    let note: Int
    let velocity: Int
    
    enum EventType {
        case noteOn
        case noteOff
    }
}

class SimpleMidiParser {
    static func frequency(for note: Int) -> Float {
        return 440.0 * pow(2.0, Float(note - 69) / 12.0)
    }
    
    func parse(url: URL) -> [MidiEvent]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        var events: [MidiEvent] = []
        let bytes = [UInt8](data)
        var offset = 0
        
        // Helper to safely read bytes
        func readBytes(_ count: Int) -> [UInt8]? {
            guard offset + count <= bytes.count else { return nil }
            let r = Array(bytes[offset..<offset+count])
            offset += count
            return r
        }
        
        func readUInt32() -> UInt32? {
            guard let b = readBytes(4) else { return nil }
            return (UInt32(b[0]) << 24) | (UInt32(b[1]) << 16) | (UInt32(b[2]) << 8) | UInt32(b[3])
        }
        
        func readUInt16() -> UInt16? {
            guard let b = readBytes(2) else { return nil }
            return (UInt16(b[0]) << 8) | UInt16(b[1])
        }
        
        func readVarInt() -> Int? {
            var value: Int = 0
            var byte: UInt8
            var count = 0
            repeat {
                guard let b = readBytes(1) else { return nil }
                byte = b[0]
                value = (value << 7) | Int(byte & 0x7F)
                count += 1
                if count > 4 { return nil }
            } while (byte & 0x80) != 0
            return value
        }
        
        // Header
        guard let chunkType = readBytes(4), String(bytes: chunkType, encoding: .ascii) == "MThd" else { return nil }
        _ = readUInt32()
        _ = readUInt16()
        let trackCount = readUInt16() ?? 0
        let timeDivision = readUInt16() ?? 480
        
        let ticksPerQuarter = Double(timeDivision & 0x7FFF)
        var tempo = 500000.0 // Default 120 BPM
        
        for _ in 0..<trackCount {
            guard offset < bytes.count else { break }
            guard let chunkID = readBytes(4), String(bytes: chunkID, encoding: .ascii) == "MTrk" else { break }
            guard let trackLen = readUInt32() else { break }
            
            let trackEnd = offset + Int(trackLen)
            var currentTime: Int = 0
            var lastStatus: UInt8 = 0
            
            while offset < trackEnd {
                guard let delta = readVarInt() else { break }
                currentTime += delta
                
                guard offset < bytes.count else { break }
                let peekByte = bytes[offset]
                
                var status: UInt8
                
                if (peekByte & 0x80) != 0 {
                    status = peekByte
                    offset += 1
                } else {
                    status = lastStatus
                }
                
                if status < 0xF0 {
                    lastStatus = status
                }
                
                let cmd = status & 0xF0
                
                switch cmd {
                case 0x80: // Note Off
                    guard let b = readBytes(2) else { break }
                    let note = Int(b[0])
                    let vel = Int(b[1])
                    let seconds = (Double(currentTime) * tempo) / (ticksPerQuarter * 1000000.0)
                    events.append(MidiEvent(timestamp: seconds, type: .noteOff, note: note, velocity: vel))
                    
                case 0x90: // Note On
                    guard let b = readBytes(2) else { break }
                    let note = Int(b[0])
                    let vel = Int(b[1])
                    let seconds = (Double(currentTime) * tempo) / (ticksPerQuarter * 1000000.0)
                    let type: MidiEvent.EventType = (vel > 0) ? .noteOn : .noteOff
                    events.append(MidiEvent(timestamp: seconds, type: type, note: note, velocity: vel))
                    
                case 0xA0, 0xB0, 0xE0: // 2 data bytes
                    _ = readBytes(2)
                    
                case 0xC0, 0xD0: // 1 data byte
                    _ = readBytes(1)
                    
                case 0xF0: // System
                    if status == 0xFF { // Meta
                        guard let _ = readBytes(1) else { break } // type
                        guard let len = readVarInt() else { break }
                        _ = readBytes(len)
                    } else if status == 0xF0 || status == 0xF7 { // Sysex
                        guard let len = readVarInt() else { break }
                        _ = readBytes(len)
                    }
                    
                default:
                    break
                }
            }
            offset = trackEnd
        }
        
        return events.sorted { $0.timestamp < $1.timestamp }
    }
}
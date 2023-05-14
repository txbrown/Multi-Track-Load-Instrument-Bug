import Foundation
import ComposableArchitecture
import AudioKit
import SwiftUI
import AVFoundation
import CoreAudio





class SongManager {
    let sequencer = AppleSequencer()
    private let mixer = Mixer()
    let engine = AudioEngine()
    var songState: Song.State
    public var instrumentsByTrack: [Int: MIDISampler] = [:]

    public init(initialSongState: Song.State = Song.State()) {
        self.songState = initialSongState
        engine.output = mixer
        do {
            try engine.start()
        } catch  {
            Log("Failed starting engine")
        }
        setupSequencer()
    }


    private func setupSequencer() {
        sequencer.rewind()
        sequencer.enableLooping()
        sequencer.setLength(Duration(beats: Double(songState.lengthInBeats)))
        sequencer.setTempo(songState.tempo)
    }

    public func update(state newState: Song.State) {
        // handle playback updates
        if newState.isPlaying {
            sequencer.enableLooping()
            sequencer.setLength(Duration(beats: Double(songState.lengthInBeats)))
            sequencer.play()
        } else {
            sequencer.stop()
        }

        // handle track updates
    }

    func addNewTrack(type: InstrumentType, trackName: String, trackID: Int) {
        if songState.isPlaying {
            sequencer.stop()
        }

        let sampler = MIDISampler(name: trackName)
        guard let newTrack = sequencer.newTrack(trackName) else { return }
        newTrack.setLoopInfo(Duration(beats: Double(songState.lengthInBeats)), loopCount: 0)
        mixer.addInput(sampler)
        newTrack.setMIDIOutput(sampler.midiIn)
        instrumentsByTrack[trackID] = sampler

        switch type {
        case .melodic:
            guard let url = Bundle.main.url(forResource: "Files/Demo", withExtension: "mid") else {
                return
            }
            
            let tempSequencer = AppleSequencer(fromURL: url)
            
            tempSequencer.tracks[2].copyAndMergeTo(musicTrack: newTrack)
        case .drum:
            guard let url = Bundle.main.url(forResource: "Files/drums", withExtension: "mid") else {
                return
            }
            
            let tempSequencer = AppleSequencer(fromURL: url)
            tempSequencer.tracks[0].copyAndMergeTo(musicTrack: newTrack)
        default:
            break
        }

        do {
            try sampler.loadInstrument(url: type.defaultPresetURL)
        } catch {
            Log("Failed to load instrument")
        }
        
        if songState.isPlaying {
            sequencer.play()
        }
    }


    func addNote(trackNumber: Int,
                 noteNumber: MIDINoteNumber,
                 velocity: MIDIVelocity,
                 position: Duration,
                 duration: Duration) {
        if sequencer.tracks.indices.contains(trackNumber) {
            sequencer.tracks[trackNumber].add(noteNumber: noteNumber, velocity: velocity, position: position, duration: duration)
        } else {
            Log("Invalid track number: \(trackNumber)")
        }
    }

    func removeNote(trackNumber: Int,
                    position: Duration,
                    duration: Duration) {
        if sequencer.tracks.indices.contains(trackNumber) {
            sequencer.tracks[trackNumber].clearRange(start: position, duration: duration)
        }
    }
}

class TrackInstrumentsManager {
    public var instrumentsByTrack: [Int: MIDISampler] = [:]

    func add(instrument: MIDISampler, trackID: Int) {
        instrumentsByTrack[trackID] = instrument
    }

    func remove(trackID: Int) {
        instrumentsByTrack.removeValue(forKey: trackID)
    }
}

struct Track: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var type: InstrumentType
        var title: String = "New track"
        var color: Color
        var id: Int
    }

    enum Action {
        case didAppear
        case delegate(DelegateAction)
    }

    enum DelegateAction {
        case didAppear(sampler: MIDISampler, name: String)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didAppear:
            return .none
        case .delegate:
            return .none
        }
    }
}

struct Song: ReducerProtocol {
    struct State: Equatable {
        var tracks: IdentifiedArrayOf<Track.State> = []
        var isPlaying = false
        var tempo: Double = 120.0
        var lengthInBeats: Int = 4
    }

    enum Action {
        case didAppear
        case didTogglePlay
        case didAddTrack(for: InstrumentType)
        case trackDelegate(Track.DelegateAction)
        case track((id: Track.State.ID, action: Track.Action))
    }


    let songManager = SongManager()
    private var trackColorOptions: [Color] = [.green, .orange, .purple, .red, .blue].shuffled()

    public init() {
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .none
            case .didTogglePlay:
                state.isPlaying.toggle()
                return .fireAndForget {[state] in
                    songManager.update(state: state)
                }
            case .didAddTrack(for: let type):
                let trackID = state.tracks.count
                let trackName = "\(type.name) - \(trackID)"
                let randomColorIndex = Int.random(in: 0...trackColorOptions.count - 1)
                let trackColor = trackColorOptions[randomColorIndex]
                let newSongTrack = Track.State(type: type, title: trackName, color: trackColor, id: trackID)
                state.tracks.append(newSongTrack)

                return .fireAndForget {
                    songManager.addNewTrack(type: type, trackName: trackName, trackID: trackID)
                }

            case .track:
                return .none
            case .trackDelegate:
                return .none
            }
        }
        .forEach(\.tracks, action: /Action.track) {
            Track()
        }
    }
}

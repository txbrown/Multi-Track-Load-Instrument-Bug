//
//  SwiftUIView.swift
//
//
//  Created by Ricardo Abreu on 04/05/2023.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation
import AudioKit

struct SongView: View {
    var store: StoreOf<Song>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                SongToolbarView(viewStore: viewStore)
                
                VStack(spacing: 40) {
                    ScrollView {
                        ForEachStore(
                            self.store.scope(state: \.tracks, action: { .track((id: $0, action: $1)) }
                                            )) { trackStore in
                                                InstrumentTrackView(store: trackStore)
                                            }
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 8)
                
                HStack {
                    Menu("+ Track") {
                        Button("Drums", action: {
                            viewStore.send(.didAddTrack(for: .drum))
                        })
                        Button("Melodic", action: {
                            viewStore.send(.didAddTrack(for: .melodic))
                        })
                    }
                    .tint(Color.white)
                }
                
                Spacer()
            }
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
    }
}

public struct SongViewPreview: View {
    var store: StoreOf<Song> = Store(initialState: Song.State(), reducer: Song())
    
    public init() {
        setupAudio()
    }
    
    public var body: some View {
        SongView(store: store)
            .preferredColorScheme(.dark)
    }
    
    func setupAudio() {
#if os(iOS)
        do {
            Settings.bufferLength = .short
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            //            logger.warning(err)
        }
#endif
    }
}

struct SongView_Previews: PreviewProvider {
    static var previews: some View {
            SongViewPreview()
    }
}

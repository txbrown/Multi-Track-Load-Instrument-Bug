//
//  ContentView.swift
//  Multi Track Load Instrument Bug
//
//  Created by Ricardo Abreu on 14/05/2023.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
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
            
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

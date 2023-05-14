import SwiftUI
import ComposableArchitecture

struct SongToolbarView: View {
    var viewStore: ViewStoreOf<Song>

    var body: some View {
        HStack {
            Button(
                action: {
                    // nav back
                },
                label: {
                    Image(systemName: "chevron.left")
                }
            )
            .foregroundColor(Color.gray)

            Spacer()

            Button(
                action: {
                    viewStore.send(.didTogglePlay)
                },
                label: {
                    Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                }
            )
            .foregroundColor(Color.white)

            Spacer()

            Button(
                action: {
                    // song settings
                },
                label: {
                    Image(systemName: "gearshape.fill")
                }
            )
            .foregroundColor(Color.white)
        }
        .padding(.bottom, 12)
        .padding(.horizontal, 40)
        .background(Color.black)
    }
}

struct SongToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        SongToolbarView(viewStore: ViewStore(Store(initialState: Song.State(), reducer: Song())))
    }
}

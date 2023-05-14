import SwiftUI
import ComposableArchitecture

enum InstrumentType {
    case drum
    case melodic
    case audio

    func icon() -> String {
        switch self {
        case .drum:
            return "Pads"
        case .melodic:
            return "Wave"
        case .audio:
            return "Mic"
        }
    }

    var name: String {
        switch self {
        case .drum:
            return "Drum track"
        case .melodic:
            return "Melodic track"
        case .audio:
            return "Audio track"
        }
    }

    var defaultPresetURL: URL {
        switch self {
        case .drum:
            return Bundle.main.url(forResource: "Files/onboarding", withExtension: "aupreset")!
        case .melodic:
            return Bundle.main.url(forResource: "Files/Candy Bee", withExtension: "sf2")!
        case .audio:
            return URL(string: "")!
        }
    }
}


struct ClipView: View {
    var color: Color = .green
    var isEmpty = false

    var body: some View {
        VStack {
            if isEmpty {
                Image(systemName: "plus")
                    .foregroundColor(color)
            }
        }
        .frame(width: 70, height: 50)
        .background(isEmpty ? nil : RoundedRectangle(cornerRadius: 6).foregroundColor(color))
        .overlay(isEmpty ? RoundedRectangle(cornerRadius: 6).stroke(color, lineWidth: 2) : nil)
        .cornerRadius(6)
    }
}

struct InstrumentTrackView: View {
    let store: StoreOf<Track>

    var body: some View {
        WithViewStore(self.store) {  viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Image(viewStore.type.icon())
                        .foregroundColor(viewStore.color)

                    Text(viewStore.title)
                        .font(.body)
                        .foregroundColor(viewStore.color)
                }


                HStack {
                    ClipView(color: viewStore.color)
                    ClipView(color: viewStore.color)
                    ClipView(color: viewStore.color, isEmpty: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 36)
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
    }
}

// struct InstrumentTrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        InstrumentTrackView(type: .drum)
//    }
// }

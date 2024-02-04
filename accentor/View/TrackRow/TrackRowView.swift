//
//  TrackRowView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 02/02/2024.
//

import SwiftUI
import GRDBQuery

struct TrackRowView: View {
    @EnvironmentStateObject private var viewModel: TrackRowViewModel
    let showNumber: Bool
    
    init(track: Track, trackArtists: [TrackArtist], showNumber: Bool = false) {
        self.showNumber = showNumber
        _viewModel = EnvironmentStateObject {
            TrackRowViewModel(database: $0.appDatabase, player: $0.player, track: track, trackArtists: trackArtists)
        }
    }
    
    var body: some View {
        HStack {
            if (showNumber) {
                Text(String(viewModel.track.number)).padding(.trailing, 20)
            }
            VStack(alignment: .leading) {
                Text(viewModel.track.title).foregroundStyle(Color.black)
                Text(TrackArtist.constructTrackArtistText(viewModel.trackArtists))
            }
            Spacer()
            Text(viewModel.track.formattedLength).monospacedDigit()
            #if os(macOS)
                contextButton
            #endif
        }.foregroundStyle(Color.gray)
            .contextMenu(menuItems: {
                TrackActions(viewModel: viewModel)
            })
    }
    
    struct TrackActions: View {
        let viewModel: TrackRowViewModel
        
        var body: some View {
            Button("Play now", action: viewModel.playTrack)
            Button("Play next", action: viewModel.playNext)
            Button("Play last", action: viewModel.playLast)
        }
    }
    
    @ViewBuilder private var contextButton: some View {
        Menu {
            TrackActions(viewModel: viewModel)
        } label: {
            ZStack {
                Circle().fill(Color(white: 0, opacity: 0)).frame(width: 30, height: 30)
                Label("Actions", systemImage: "ellipsis")
                    .foregroundStyle(Color.accentColor)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 15))
            }
        }.buttonStyle(.plain)
    }
}

//#Preview {
//    TrackRowView()
//}

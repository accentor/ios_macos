//
//  ArtistView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI
import GRDBQuery

struct ArtistView: View {
    @EnvironmentStateObject private var viewModel: ArtistViewModel
    
    init(id: Artist.ID) {
        _viewModel = EnvironmentStateObject {
            ArtistViewModel(database: $0.appDatabase, id: id)
        }
    }

    var body: some View {
        if let artist = viewModel.artistInfo?.artist {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        if (artist.image250 != nil) {
                            CachedImage(imageURL: artist.image250) {
                                ZStack {
                                    Rectangle().fill(.gray)
                                    Image(systemName: "music.mic").font(.largeTitle)
                                }
                            }.frame(maxWidth: 250, maxHeight: 250)
                        }
                        Text(artist.name)
                    }
                    Text("Albums")
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.artistInfo!.albums) { item in
                                AlbumCard(id: item.id).frame(minWidth: 130, maxWidth: 200)
                            }
                        }
                    }
                    Text("Tracks")
                    ForEach(viewModel.artistInfo!.tracks) { track in
                        Text(track.title)
                    }
                }
            }.navigationTitle(artist.name)
        } else {
            ProgressView()
        }
    }
}


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
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    init(id: Artist.ID) {
        _viewModel = EnvironmentStateObject {
            ArtistViewModel(database: $0.appDatabase, id: id)
        }
    }
    
    var body: some View {
        if let artist = viewModel.artistInfo?.artist {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        if (artist.image250 != nil) {
                            CachedImage(imageURL: artist.image250) {
                                ZStack {
                                    Rectangle().fill(.gray)
                                    Image(systemName: "music.mic").font(.largeTitle)
                                }
                            }.frame(maxWidth: 250, maxHeight: 250)
                        }
                        Text(artist.name).font(.headline)
                    }.padding(10)
                    Section(content: {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 5) {
                                ForEach(viewModel.artistInfo!.albums) { item in
                                    AlbumCard(id: item.id).frame(width: 200, height: 250)
                                }
                            }.padding(.horizontal, 8)
                        }
                    }, header: {
                        Text("Albums").padding(.horizontal, 12).font(.subheadline)
                    })
                    Section(content: {
                        ForEach(viewModel.artistInfo!.tracks, id: \.track.id) { trackInfo in
                            TrackRowView(track: trackInfo.track, trackArtists: trackInfo.trackArtists).padding(.horizontal, 12)
                            Divider()
                        }
                    }, header: {
                        Text("Tracks").padding(.horizontal, 12).font(.subheadline)
                        Divider()
                    })
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 75, trailing: 0))
            }.navigationTitle(artist.name)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        } else {
            ProgressView()
        }
    }
}


//
//  AlbumView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 24/01/2024.
//

import SwiftUI
import GRDBQuery

struct AlbumView: View {
    @EnvironmentStateObject private var viewModel: AlbumViewModel
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    init(id: Album.ID) {
        _viewModel = EnvironmentStateObject {
            AlbumViewModel(database: $0.appDatabase, player: $0.player, id: id)
        }
    }
    
    var body: some View {
        if let album = viewModel.albumInfo?.album {
            ScrollView {
                VStack {
                    CachedImage(imageURL: album.image250) {
                        GeometryReader { geometry in
                            ZStack {
                                Rectangle().fill(.gray)
                                Image(systemName: "music.note").font(.largeTitle)
                            }.frame(width: geometry.size.width, height: geometry.size.width)
                        }
                    }.scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(radius: 6, x: -3, y: 3)
                    
                    Text(album.title).font(.title)
                    Text(AlbumArtist.constructAlbumArtistText(viewModel.albumInfo?.albumArtists)).foregroundStyle(Color.accentColor)
                    
                    HStack {
                        Button(action: viewModel.playAlbum, label: {
                            Label("Play", systemImage: "play.fill")
                        })
                        
                        Button(action: viewModel.shuffleAlbum, label: {
                            Label("Shuffle", systemImage: "shuffle")
                        })
                    }.buttonStyle(.borderedProminent)
                    Section(content: {
                        Divider()
                        ForEach(viewModel.albumInfo!.tracks, id: \.track.id) { trackInfo in
                            TrackRowView(track: trackInfo.track, trackArtists: trackInfo.trackArtists, showNumber: true).padding(.horizontal, 12)
                            Divider()
                        }
                    }, footer: {
                        // Add padding here, so the view scrolls under the player
                        Text(viewModel.tracksStats).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).font(.caption2).foregroundStyle(Color.gray)
                    })
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 75, trailing: 0))
            }
            .navigationTitle(album.title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    Menu {
                        Button("Play “\(viewModel.albumInfo!.album.title)”", action: viewModel.playAlbum)
                        Button("Shuffle “\(viewModel.albumInfo!.album.title)”", action: viewModel.shuffleAlbum)
                        Button("Play next", action:  viewModel.playNext)
                        Button("Play last", action: viewModel.playLast)
                    } label: {
                        Label("Actions", systemImage: "ellipsis")
                    }
                })
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    AlbumView(id: 1)
}

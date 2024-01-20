//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import GRDBQuery

struct AlbumCard: View {
    @EnvironmentStateObject private var viewModel: AlbumCardViewModel
    
    init(id: Album.ID) {
        _viewModel = EnvironmentStateObject {
            AlbumCardViewModel(database: $0.appDatabase, id: id)
        }
    }

    var body: some View {
        if let album = viewModel.albumInfo?.album {
            VStack(alignment: .leading) {
                CachedImage(imageURL: album.image250) {
                    ZStack {
                        Rectangle().fill(.gray)
                        Image(systemName: "music.note").font(.largeTitle)
                    }
                }.aspectRatio(1, contentMode: .fit)
                Text(album.title)
                Text(AlbumArtist.constructAlbumArtistText(viewModel.albumInfo?.albumArtists))
                Spacer()
            }.onTapGesture {
                Task { await viewModel.queueAlbum() }
            }
        } else {
            ProgressView()
        }
    }
}

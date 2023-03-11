//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import CachedAsyncImage

struct AlbumCard: View {
    var album: Album

    var body: some View {
        VStack(alignment: .leading) {
            AlbumImage(album: album)
            Text(album.title ?? "")
            Text(album.albumArtistsText)
            Spacer()
        }.onTapGesture {
            PlayQueue.shared.addAlbumToQueue(album: album, replace: true)
        }
    }
}

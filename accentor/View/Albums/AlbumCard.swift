//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI

struct AlbumCard: View {
    var album: Album

    var body: some View {
        VStack(alignment: .leading) {
            CachedImage(imageURL: album.image250) {
                ZStack {
                    Rectangle().fill(.gray)
                    Image(systemName: "music.note").font(.largeTitle)
                }
            }.aspectRatio(1, contentMode: .fit)
            Text(album.title ?? "")
            Text(album.albumArtistsText)
            Spacer()
        }.onTapGesture {
            PlayQueue.shared.addAlbumToQueue(album: album, replace: true)
        }
    }
}

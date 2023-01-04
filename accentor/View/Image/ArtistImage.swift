//
//  ArtistImage.swift
//  accentor
//
//  Created by Robbe Van Petegem on 04/01/2023.
//

import SwiftUI
import CachedAsyncImage

struct ArtistImage: View {
    var artist: Artist

    var body: some View {
        if (artist.image250 != nil) {
            CachedAsyncImage(url: URL(string: artist.image250!)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fit)
                } else {
                    ZStack {
                        Rectangle().fill(.gray)
                        Image(systemName: "music.mic").font(.largeTitle)
                    }.aspectRatio(1, contentMode: .fit)
                }
            }
        } else {
            ZStack {
                Rectangle().fill(Color.gray)
                Image(systemName: "music.mic").font(.largeTitle)
            }.aspectRatio(1, contentMode: .fit)

        }
    }
}

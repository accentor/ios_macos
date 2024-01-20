//
//  ArtistCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI

struct ArtistCard: View {
    var artist: Artist

    var body: some View {
        VStack(alignment: .leading) {
            CachedImage(imageURL: artist.image250) {
                ZStack {
                    Rectangle().fill(.gray)
                    Image(systemName: "music.mic").font(.largeTitle)
                }
            }.aspectRatio(1, contentMode: .fit)
            Text(artist.name)
            Spacer()
        }
    }
}

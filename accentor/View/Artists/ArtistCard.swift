//
//  ArtistCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI
import CachedAsyncImage

struct ArtistCard: View {
    var artist: Artist

    var body: some View {
        VStack(alignment: .leading) {
            ArtistImage(artist: artist)
            Text(artist.name!)
            Spacer()
        }
    }
}

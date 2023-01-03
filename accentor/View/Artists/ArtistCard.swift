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
            if (artist.image250 != nil) {
                AsyncImage(url: URL(string: artist.image250!)) { phase in
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
            Text(artist.name!)
            Spacer()
        }
    }
}

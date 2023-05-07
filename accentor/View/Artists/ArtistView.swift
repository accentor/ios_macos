//
//  ArtistView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI

struct ArtistView: View {
    var artist: Artist

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    if (artist.image250 != nil) {
                        CachedImage(imageURL: artist.image250) {
                            ZStack {
                                Rectangle().fill(.gray)
                                Image(systemName: "music.mic").font(.largeTitle)
                            }
                        }
                    }
                    Text(artist.name ?? "")
                }
                Text("Albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(artist.albums) { item in
                            AlbumCard(album: item).frame(minWidth: 130, maxWidth: 200)
                        }
                    }
                }
                Text("Tracks")
                ForEach(artist.tracks) { track in
                    Text(track.title ?? "")
                }
            }
        }.navigationTitle(artist.name ?? "")
    }
}


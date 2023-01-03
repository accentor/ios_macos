//
//  ArtistView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI

struct ArtistView: View {
    var artist: Artist
    var albums: [Album] = []
    var tracks: [Track] = []
    
    init(artist: Artist) {
        self.artist = artist
        if let albumArtists = artist.albumArtists {
            self.albums = albumArtists.map({ item in
                let aa = item as! AlbumArtist
                return aa.album!
            })
        }
        if let trackArtists = artist.trackArtists {
            self.tracks = trackArtists.map({ item in
                let ta = item as! TrackArtist
                return ta.track!
            })
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    if (artist.image250 != nil) {
                        AsyncImage(url: URL(string: artist.image250!))
                    }
                    Text(artist.name ?? "")
                }
                Text("Albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(albums) { item in
                            AlbumCard(album: item).frame(minWidth: 130, maxWidth: 200)
                        }
                    }
                }
                Text("Tracks")
                ForEach(tracks) { track in
                    Text(track.title ?? "")
                }
            }
        }.navigationTitle(artist.name ?? "")
    }
}


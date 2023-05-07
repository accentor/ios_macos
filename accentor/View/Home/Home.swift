//
//  Home.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/05/2023.
//

import SwiftUI

struct Home: View {
    @FetchRequest(entity: Album.entity(), sortDescriptors: Album.sortByRecentlyReleased) var recentlyReleasedAlbums : FetchedResults<Album>
    @FetchRequest(entity: Album.entity(), sortDescriptors: Album.sortByRecentlyAdded) var recentlyAddedAlbums : FetchedResults<Album>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recently released")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(recentlyReleasedAlbums) { item in
                            AlbumCard(album: item).frame(width: 200)
                        }
                    }
                }
                Text("Recently added albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(recentlyAddedAlbums) { item in
                            AlbumCard(album: item).frame(width: 200)
                        }
                    }
                }
                Text("Random albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(recentlyAddedAlbums.shuffled()) { item in
                            AlbumCard(album: item).frame(width: 200)
                        }
                    }
                }
            }
        }.navigationTitle("Home")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

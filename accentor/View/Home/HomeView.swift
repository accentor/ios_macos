//
//  Home.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/05/2023.
//

import SwiftUI
import GRDBQuery

struct HomeView: View {
    @EnvironmentStateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = EnvironmentStateObject {
            HomeViewModel(database: $0.appDatabase)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recently released albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(viewModel.recentlyReleasedAlbums) { item in
                            AlbumCard(id: item.id).frame(width: 200)
                        }
                    }
                }
                Text("Recently added albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(viewModel.recentlyAddedAlbums) { item in
                            AlbumCard(id: item.id).frame(width: 200)
                        }
                    }
                }
                Section("On this day") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.onThisDay) { item in
                                AlbumCard(id: item.id).frame(width: 200)
                            }
                        }
                    }
                }
                Section("Recently played albums") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.recentlyPlayedAlbums) { album in
                                AlbumCard(id: album.id).frame(width: 200)
                            }
                        }
                    }
                }
                Section("Recently added artists") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.recentlyAddedArtists) { artist in
                                ArtistCard(artist: artist).frame(width: 200)
                            }
                        }
                    }
                }
                Section("Recently played artists") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.recentlyPlayedArtists) { artist in
                                ArtistCard(artist: artist).frame(width: 200)
                            }
                        }
                    }
                }
                Section("Random albums") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.randomAlbums) { item in
                                AlbumCard(id: item.id).frame(width: 200)
                            }
                        }
                    }
                }
                Section("Random artists") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 5) {
                            ForEach(viewModel.randomArtists) { artist in
                                ArtistCard(artist: artist).frame(width: 200)
                            }
                        }
                    }
                }
            }
        }.padding().navigationTitle("Home")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

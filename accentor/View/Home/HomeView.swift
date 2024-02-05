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
                AlbumsSection(title: "Recently released albums", albums: viewModel.recentlyReleasedAlbums)
                AlbumsSection(title: "Recently added albums", albums: viewModel.recentlyAddedAlbums)
                AlbumsSection(title: "On this day", albums: viewModel.onThisDay)
                AlbumsSection(title: "Recently played albums", albums: viewModel.recentlyPlayedAlbums)
                ArtistsSection(title: "Recently added artists", artists: viewModel.recentlyAddedArtists)
                ArtistsSection(title: "Recently played artists", artists: viewModel.recentlyPlayedArtists)
                AlbumsSection(title: "Random albums", albums: viewModel.randomAlbums)
                ArtistsSection(title: "Random artists", artists: viewModel.randomArtists)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 75, trailing: 0))
        }.navigationTitle("Home")
    }
    
    struct ArtistsSection: View {
        let title: String
        let artists: [Artist]
        
        var body: some View {
            Section(content: {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(artists) { item in
                            ArtistCard(artist: item).frame(width: 200, height: 240)
                        }
                    }.modify {
                        if #available(macOS 14.0, iOS 17.0, *) {
                            $0.scrollTargetLayout()
                        } else {
                            $0.padding(.horizontal, 8)
                        }
                    }
                }.modify {
                    if #available(macOS 14.0, iOS 17.0, *) {
                        $0.scrollTargetBehavior(.viewAligned)
                            .safeAreaPadding(.horizontal, 8)
                    } else {
                        $0
                    }
                }
            }, header: {
                Text(title).padding(.horizontal, 12)
            })
        }
    }
    
    struct AlbumsSection: View {
        let title: String
        let albums: [Album]
        
        var body: some View {
            Section(content: {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(albums) { item in
                            AlbumCard(id: item.id).frame(width: 200, height: 250)
                        }
                    }.modify {
                        if #available(macOS 14.0, iOS 17.0, *) {
                            $0.scrollTargetLayout()
                        } else {
                            $0.padding(.horizontal, 8)
                        }
                    }
                }.modify {
                    if #available(macOS 14.0, iOS 17.0, *) {
                        $0.scrollTargetBehavior(.viewAligned)
                            .safeAreaPadding(.horizontal, 8)
                    } else {
                        $0
                    }
                }
            }, header: {
                Text(title).padding(.horizontal, 12)
            })
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

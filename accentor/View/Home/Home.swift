//
//  Home.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/05/2023.
//

import SwiftUI
import GRDBQuery

struct Home: View {
    @EnvironmentStateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = EnvironmentStateObject {
            HomeViewModel(database: $0.appDatabase)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recently released")
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
                Text("Random albums")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(viewModel.recentlyAddedAlbums.shuffled()) { item in
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
            }
        }.padding().navigationTitle("Home")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

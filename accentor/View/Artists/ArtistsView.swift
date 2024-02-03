//
//  Artists.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI
import GRDBQuery


struct ArtistsView: View {
    @EnvironmentStateObject private var viewModel: ArtistsViewModel

    init() {
        _viewModel = EnvironmentStateObject {
            ArtistsViewModel(database: $0.appDatabase)
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 130))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.artists) { artist in
                    NavigationLink(value: artist) {
                        ArtistCard(artist: artist)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }.navigationTitle("Artists")
        .searchable(text: $viewModel.searchTerm)
    }
}

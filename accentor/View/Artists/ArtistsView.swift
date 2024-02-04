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
        GridItem(.adaptive(minimum: 162, maximum: 252))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.artists) { artist in
                    NavigationLink(value: artist) {
                        ArtistCard(artist: artist)
                    }.buttonStyle(PlainButtonStyle())
                }
            }.padding(EdgeInsets(top: 20, leading: 30, bottom: 65, trailing: 30))
        }.navigationTitle("Artists")
        .searchable(text: $viewModel.searchTerm)
    }
}

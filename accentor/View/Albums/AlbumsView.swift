//
//  Albums.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI
import GRDBQuery

struct AlbumsView: View {
    @EnvironmentStateObject private var viewModel: AlbumsViewModel

    init() {
        _viewModel = EnvironmentStateObject {
            AlbumsViewModel(database: $0.appDatabase)
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 130))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.albumIds, id: \.self) { albumId in AlbumCard(id: albumId) }
            }
        }.navigationTitle("Albums")
         .searchable(text: $viewModel.searchTerm)
    }
}

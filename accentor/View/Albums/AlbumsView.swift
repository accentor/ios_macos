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
        GridItem(.adaptive(minimum: 162, maximum: 252))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.albumIds, id: \.self) { albumId in
                    AlbumCard(id: albumId)
                }
            }.modify {
                if #available(macOS 14.0, iOS 17.0, *) {
                    $0.scrollTargetLayout()
                } else {
                    $0.padding(EdgeInsets(top: 4, leading: 30, bottom: 65, trailing: 30))
                }
            }
            
        }.modify {
            if #available(macOS 14.0, iOS 17.0, *) {
                $0.scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(EdgeInsets(top: 4, leading: 30, bottom: 65, trailing: 30))
            } else {
                $0
            }
        }.searchable(text: $viewModel.searchTerm).navigationTitle("Albums")
    }
}

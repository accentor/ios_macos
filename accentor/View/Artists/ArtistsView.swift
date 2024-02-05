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
        }.navigationTitle("Artists")
            .searchable(text: $viewModel.searchTerm)
    }
}

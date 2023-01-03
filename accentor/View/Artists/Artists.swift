//
//  Artists.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI
import CoreData

struct Artists: View {
    @State var searchTerm: String = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 130))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    FilteredArtists(filter: searchTerm)
                }
            }.navigationDestination(for: Artist.self) { artist in
                ArtistView(artist: artist)
            }.toolbar {
                TextField("Search", text: $searchTerm)
            }

        }.navigationTitle("Artists")
            
    }
}

private struct FilteredArtists: View {
    @FetchRequest var artists: FetchedResults<Artist>
    
    init(filter: String) {
        let fetchRequest: NSFetchRequest<Artist> = Artist.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Artist.normalizedName, ascending: true)]
        if (filter.count > 0) {
            fetchRequest.predicate = NSPredicate(format: "normalizedName CONTAINS %@", filter.lowercased())
        }
        _artists = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ForEach(artists) { artist in
            NavigationLink(value: artist) {
                ArtistCard(artist: artist)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

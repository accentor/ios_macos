//
//  Albums.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI
import CoreData

struct Albums: View {
    @State var searchTerm: String = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 130))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                FilteredAlbums(filter: searchTerm)
            }.toolbar {
                TextField("Search", text: $searchTerm)
            }
        }.navigationTitle("Albums")
    }
}

private struct FilteredAlbums: View {
    @FetchRequest var albums: FetchedResults<Album>
    
    init(filter: String) {
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Album.normalizedTitle, ascending: true)]
        if (filter.count > 0) {
            fetchRequest.predicate = NSPredicate(format: "normalizedTitle CONTAINS %@", filter.lowercased())
        }
        _albums = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ForEach(albums) { album in AlbumCard(album: album) }
    }
}

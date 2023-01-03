//
//  Tracks.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI

struct Tracks: View {
    @FetchRequest(entity: Track.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Track.title, ascending: true)]) var tracks : FetchedResults<Track>
    
    var body: some View {
        List(tracks) { track in
            TrackRow(track: track)
        }.navigationTitle("Track")
//        ScrollView {
//            LazyVGrid(columns: columns) {
//                ForEach(albums) { album in AlbumCard(album: album) }
//            }
//        }
    }
}

struct Tracks_Previews: PreviewProvider {
    static var previews: some View {
        Tracks()
    }
}

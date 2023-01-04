//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import CachedAsyncImage

struct AlbumCard: View {
    var album: Album
    
    func albumArtistsText() -> String {
        guard let albumArtists = album.albumArtists else { return "Various Artists" }
        
        let sorted = albumArtists.sortedArray(using: [NSSortDescriptor(key: "order", ascending: true)])
        return sorted.reduce("", { acc, cur in
            // NOTE: I'm note sure why this reducer looses the context if which type `cur`
            // For now we simply force this to be an album artist
            let aa = cur as! AlbumArtist
            return "\(acc)\(aa.name ?? "")\(aa.separator ?? "")"
        })
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            AlbumImage(album: album)
            Text(album.title ?? "")
            Text(albumArtistsText())
            Spacer()
        }.onTapGesture {
            PlayQueue.shared.addAlbumToQueue(album: album, replace: true)
        }
    }
}

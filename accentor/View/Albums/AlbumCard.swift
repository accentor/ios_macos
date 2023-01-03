//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI

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
            if (album.image250 != nil) {
                AsyncImage(url: URL(string: album.image250!)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        ZStack {
                            Rectangle().fill(.gray)
                            Image(systemName: "music.note").font(.largeTitle)
                        }.aspectRatio(1, contentMode: .fit)
                    }
                }
            } else {
                ZStack {
                    Rectangle().fill(Color.gray)
                    Image(systemName: "music.note").font(.largeTitle)
                }.aspectRatio(1, contentMode: .fit)
                
            }
            Text(album.title ?? "")
            Text(albumArtistsText())
            Spacer()
        }.onTapGesture {
            PlayQueue.shared.addAlbumToQueue(album: album, replace: true)
        }
    }
}

//struct AlbumCard_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumCard()
//    }
//}

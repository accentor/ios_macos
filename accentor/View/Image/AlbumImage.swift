//
//  AlbumImage.swift
//  accentor
//
//  Created by Robbe Van Petegem on 04/01/2023.
//

import SwiftUI
import CachedAsyncImage

struct AlbumImage: View {
    var album: Album
    
    
    var body: some View {
        if (album.image250 != nil) {
            CachedAsyncImage(url: URL(string: album.image250!)) { phase in
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
    }
}

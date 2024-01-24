//
//  AlbumCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import GRDBQuery

struct AlbumCard: View {
    @EnvironmentStateObject private var viewModel: AlbumCardViewModel
    
    init(id: Album.ID) {
        _viewModel = EnvironmentStateObject {
            AlbumCardViewModel(database: $0.appDatabase, id: id)
        }
    }
    var body: some View {
        if let album = viewModel.albumInfo?.album {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    CachedImage(imageURL: album.image250) {
                        ZStack {
                            Rectangle().fill(.gray)
                            Image(systemName: "music.note").font(.largeTitle)
                        }
                    }.scaledToFill()
                        .clipped()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                    
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(radius: 6, x: -3, y: 3)
                    
                }.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                VStack(alignment: .leading) {
                    Text(album.title).lineLimit(2)
                    Text(AlbumArtist.constructAlbumArtistText(viewModel.albumInfo?.albumArtists)).foregroundColor(.gray).lineLimit(1)
                }.truncationMode(.tail).font(.system(size: 12))
                
                Spacer()
            }.onTapGesture {
                Task { await viewModel.queueAlbum() }
            }.padding(.horizontal, 6)
        } else {
            ProgressView()
        }
    }
}

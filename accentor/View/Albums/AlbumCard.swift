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
            AlbumCardViewModel(database: $0.appDatabase, player: $0.player, id: id)
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
                    .overlay(overlay)
                    .onHover { isHovered in
                        viewModel.isHovered = isHovered
                    }
                VStack(alignment: .leading) {
                    Text(album.title).lineLimit(2)
                    Text(AlbumArtist.constructAlbumArtistText(viewModel.albumInfo?.albumArtists)).foregroundColor(.gray).lineLimit(1)
                }.truncationMode(.tail).font(.system(size: 12))
                
                Spacer()
            }.onTapGesture {
                viewModel.queueAlbum()
            }.padding(.horizontal, 6)
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder private var overlay: some View {
        if viewModel.isHovered {
            ZStack {
                Color(white: 0, opacity: 0.15)
                VStack {
                    Spacer()
                    HStack(alignment: .bottom, content: {
                        PlayButton(viewModel: viewModel)
                        Spacer()
                        ContextActions(viewModel: viewModel)
                    })
                }.padding(10)
            }
            
        }
    }
    
    struct PlayButton: View {
        @State var isHovered: Bool = false
        let viewModel: AlbumCardViewModel
        
        var body: some View {
            Button(action: { viewModel.queueAlbum() }, label: {
                ZStack {
                    Circle().fill(isHovered ? Color.accentColor : Color(white: 0, opacity: 0.25)).frame(width: 30, height: 30)
                    Label("Play", systemImage: "play.fill")
                        .foregroundStyle(Color.white)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 15))
                }
            }).buttonStyle(.plain)
                .onHover(perform: { isHovered in
                    self.isHovered = isHovered
                })
        }
    }
    
    struct ContextActions: View {
        @State var isHovered: Bool = false
        let viewModel: AlbumCardViewModel
        
        var body: some View {
            Menu {
                Button("Play “\(viewModel.albumInfo!.album.title)”", action: { viewModel.queueAlbum() })
                Button("Shuffle “\(viewModel.albumInfo!.album.title)”", action: { viewModel.queueAlbum(shuffled: true) })
                Button("Play next", action:  { viewModel.queueAlbum(replace: false, position: .next) })
                Button("Play last", action: { viewModel.queueAlbum(replace: false, position: .last) })
            } label: {
                ZStack {
                    Circle().fill(isHovered ? Color.accentColor : Color(white: 0, opacity: 0.25)).frame(width: 30, height: 30)
                    Label("Actions", systemImage: "ellipsis")
                        .foregroundStyle(Color.white)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 15))
                }.onHover(perform: { hovering in
                    self.isHovered = hovering
                })
            }.buttonStyle(.plain)
        }
    }
}


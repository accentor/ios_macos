//
//  ArtistCard.swift
//  accentor
//
//  Created by Robbe Van Petegem on 30/12/2022.
//

import SwiftUI

struct ArtistCard: View {
    var artist: Artist

    var body: some View {
        NavigationLink(value: artist) {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    CachedImage(imageURL: artist.image250) {
                        ZStack {
                            Rectangle().fill(.gray)
                            Image(systemName: "music.mic").font(.largeTitle)
                        }
                    }.scaledToFill()
                        .clipped()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(radius: 6, x: -3, y: 3)
                }.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                Text(artist.name).lineLimit(2).truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/).font(.system(size: 12))
                Spacer()
            }.padding([.horizontal, .top], 6)
        }.buttonStyle(.plain)
    }
}

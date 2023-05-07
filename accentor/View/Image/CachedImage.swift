//
//  CachedImage.swift
//  accentor
//
//  Created by Robbe Van Petegem on 07/05/2023.
//

import SwiftUI

struct CachedImage<Content: View>: View {
    @State var imageURL: String?
    @ViewBuilder let fallback: Content
    @StateObject var viewModel = CachedImageViewModel()

    
    var body: some View {
        Group {
            if (imageURL != nil && viewModel.image != nil) {
                #if os(macOS)
                Image(nsImage: viewModel.image!).resizable()
                #else
                Image(uiImage: viewModel.image!).resizable()
                #endif
            } else {
                self.fallback
            }
        }
        .task {
            await viewModel.getImage(imageURL: imageURL)
        }
        
    }
}



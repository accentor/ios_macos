//
//  CachedImageViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 07/05/2023.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class CachedImageViewModel: ObservableObject {
    #if os(macOS)
    @Published var image: NSImage?
    #else
    @Published var image: UIImage?
    #endif
    
    @MainActor
    func getImage(imageURL: String?) async {
        guard imageURL != nil, let imageURL = URL(string: imageURL!) else { return }
        
        let imageRepository = ImageRepository()
        self.image = await imageRepository.getImage(imageURL: imageURL)
    }
}

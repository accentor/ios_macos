//
//  AppWrapperViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import CoreData

class AppWrapperViewModel: ObservableObject {
    func setDefaultSettings() {
        // Always set this key, to apply new default settings
        UserDefaults.standard.set(DefaultSettings.codecConversionId, forKey: "codecConversionId")
    }
    
    func fetchAll(context: NSManagedObjectContext) {
        AlbumService.shared.index(context: context)
        ArtistService.shared.index(context: context)
        TrackService.shared.index(context: context)
    }
}



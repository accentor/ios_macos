//
//  AppWrapperViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import CoreData

class AppWrapperViewModel: ObservableObject {
    func setDefaultSettings() {
        if (UserDefaults.standard.object(forKey: "codecConversionId") == nil) {
            UserDefaults.standard.set(DefaultSettings.codecConversionId, forKey: "codecConversionId")
        }
    }
    
    func fetchAll(context: NSManagedObjectContext) {
        AlbumService.shared.index(context: context)
        ArtistService.shared.index(context: context)
        TrackService.shared.index(context: context)
    }
}



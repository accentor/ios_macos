//
//  Artist+CoreDataClass.swift
//  accentor
//
//  Created by Robbe Van Petegem on 11/03/2023.
//

import Foundation
import CoreData

@objc(Artist)
public class Artist: NSManagedObject {
    var albums: [Album] {
        get {
            self.albumArtists.map({ item in return item.album! }).sorted { a1, a2 in
                guard let r1 = a1.releaseDate else { return true }
                guard let r2 = a2.releaseDate else { return false }
                
                return r1 < r2
            }
        }
    }
    
    var albumArtists: [AlbumArtist] {
        get {
            let fetchRequest: NSFetchRequest<AlbumArtist> = AlbumArtist.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "artistId == %i", self.id)
            return try! PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        }
    }
    
    var tracks: [Track] {
        get {
            self.trackArtists.map({ item in item.track! }).sorted { t1, t2 in
                guard let title1 = t1.normalizedTitle else { return false }
                guard let title2 = t2.normalizedTitle else { return true }
                
                return title1 < title2
            }
        }
    }
    
    var trackArtists: [TrackArtist] {
        get {
            let fetchRequest: NSFetchRequest<TrackArtist> = TrackArtist.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "artistId == %i", self.id)
            return try! PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        }
    }
}

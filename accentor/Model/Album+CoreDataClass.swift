//
//  Album+CoreDataClass.swift
//  accentor
//
//  Created by Robbe Van Petegem on 11/03/2023.
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject {
    var albumArtistsText: String {
        get {
            guard let albumArtists = self.albumArtists else { return "Various Artists" }
            
            let sorted = albumArtists.sortedArray(using: [NSSortDescriptor(key: "order", ascending: true)])
            return sorted.reduce("", { acc, cur in
                // NOTE: I'm note sure why this reducer looses the context if which type `cur`
                // For now we simply force this to be an album artist
                let aa = cur as! AlbumArtist
                return "\(acc)\(aa.name ?? "")\(aa.separator ?? "")"
            })

        }
    }
    
    var tracks: [Track] {
        get {
            let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.number, ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "albumId == %i", self.id)
            return try! PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        }
    }
}

extension Album {
    static var sortByRecentlyReleased: [NSSortDescriptor] {
        return [
            NSSortDescriptor(keyPath: .releaseDate, ascending: false)
        ]
    }

    static var sortByRecentlyAdded: [NSSortDescriptor] {
        return [
            NSSortDescriptor(keyPath: .createdAt, ascending: false)
        ]
    }
}

//
//  Track+CoreDataClass.swift
//  accentor
//
//  Created by Robbe Van Petegem on 22/01/2023.
//
//

import Foundation
import CoreData

@objc(Track)
public class Track: NSManagedObject {
    var album: Album? {
        get {
            let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", self.albumId)
            return try! PersistenceController.shared.container.viewContext.fetch(fetchRequest).first ?? nil
        }
    }
    var trackArtistsText: String {
        get {
            guard let trackArtists = self.trackArtists else { return "" }
            
            let sorted = trackArtists.sortedArray(using: [NSSortDescriptor(key: "order", ascending: true)])
            let names = sorted.map { cur in
                // NOTE: I'm note sure why this reducer looses the context if which type `cur`
                // For now we simply force this to be an album artist
                let aa = cur as! TrackArtist
                return aa.name ?? ""
            }
            return names.joined(separator: " / ")
        }
    }
}

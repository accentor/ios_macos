//
//  TrackService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import CoreData

struct TrackService {
    let apiPath = "tracks";
    public static let shared = TrackService()
    
    func index(context: NSManagedObjectContext) {
        AbstractService.shared.index(path: apiPath, entityName: "Track", completion: { jsonData in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let tracks = try decoder.decode([APITrack].self, from: jsonData)

                DispatchQueue.main.async {
                    self.saveTracks(context: context, tracks: tracks)
                }
            } catch {
                print("Error decoding tracks")
                print(error)
            }
            
        })
    }
    
    private func saveTracks(context: NSManagedObjectContext, tracks: [APITrack]) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
            tracks.forEach { (track) in
                let entity: Track!
                
                let fetchTrack: NSFetchRequest<Track> = Track.fetchRequest()
                fetchTrack.predicate = NSPredicate(format: "id == %ld", track.id)
                
                let results = try? context.fetch(fetchTrack)
                if results?.count == 0 {
                    entity = Track(context: context)
                    entity.id = track.id
                } else {
                    entity = results?.first
                }

                entity.title = track.title
                entity.normalizedTitle = track.normalizedTitle
                entity.number = track.number
                // TODO: It seems weird that we have to check and unwrap, while our properties in core data are optional
                // Also: maybe combine these checks? They _should_ all be true/false at the same time
                if (track.locationId != nil) {
                    entity.locationId = track.locationId!
                }
                if (track.codecId != nil) {
                    entity.codecId = track.codecId!
                }
                if (track.length != nil) {
                    entity.length = track.length!
                }

                entity.fetchedAt = Date()
                entity.albumId = track.albumId
                
                // Look for the album and re-create the association
                let fetchAlbum: NSFetchRequest<Album> = Album.fetchRequest()
                fetchAlbum.predicate = NSPredicate(format: "id == %ld", track.albumId)
                let album = try? context.fetch(fetchAlbum).first
                entity.album = album
                
                if (track.trackArtists  != []) {
                    track.trackArtists.forEach { (trackArtist) in
                        let nestedEntity = TrackArtist(context: context)
                        nestedEntity.track = entity
                        nestedEntity.artistId = trackArtist.artistId
                        nestedEntity.name = trackArtist.name
                        nestedEntity.normalizedName = trackArtist.normalizedName
                        nestedEntity.order = trackArtist.order
                        nestedEntity.role = trackArtist.role
                        nestedEntity.hidden = trackArtist.hidden
                        
                        // Look for the artist and re-create the association
                        let fetchArtist: NSFetchRequest<Artist> = Artist.fetchRequest()
                        fetchArtist.predicate = NSPredicate(format: "id == %ld", trackArtist.artistId)
                        let artist = try? context.fetch(fetchArtist).first
                        nestedEntity.artist = artist
                    }
                
                }
            }
            
            try context.save();
            print("successfully saved tracks")
        } catch {
            print(error)
        }
    }
}

struct APITrackArtist: Decodable, Hashable {
    var artistId: Int64
    var name: String
    var normalizedName: String
    var order: Int16
    var role: String
    var hidden: Bool
}

struct APITrack: Decodable, Hashable {
    var id: Int64
    var title: String
    var normalizedTitle: String
    var albumId: Int64
    var number: Int16
    
    // Audio properties
    var bitrate: Int16?
    var locationId: Int64?
    var length: Int16?
    var codecId: Int64?
    
    // Track artists
    var trackArtists: [APITrackArtist] = []
}

//
//  ArtistService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 28/12/2022.
//

import Foundation
import CoreData

struct ArtistService {
    let apiPath = "artists"
    public static let shared = ArtistService()
    
    func index(context: NSManagedObjectContext) {
        let startLoading = NSDate()
        
        AbstractService.shared.index(path: apiPath, entityName: "Artist", completion: { jsonData in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let artists = try decoder.decode([APIArtist].self, from: jsonData)
                
                DispatchQueue.main.async {
                    self.saveArtists(context: context, artists: artists)
                }
            } catch {
                print("Error decoding artists")
            }
        })
    }
    
    private func saveArtists(context: NSManagedObjectContext, artists: [APIArtist]) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
            artists.forEach { (artist) in
                let entity: Artist!
                
                let fetchArtist: NSFetchRequest<Artist> = Artist.fetchRequest()
                fetchArtist.predicate = NSPredicate(format: "id == %ld", artist.id)
                
                let results = try? context.fetch(fetchArtist)
                if results?.count == 0 {
                    entity = Artist(context: context)
                    entity.id = artist.id
                } else {
                    entity = results?.first
                }
                
                entity.name = artist.name
                entity.normalizedName = artist.normalizedName
                entity.image = artist.image
                entity.image100 = artist.image100
                entity.image250 = artist.image250
                entity.image500 = artist.image500
                entity.imageType = artist.imageType
                entity.fetchedAt = Date()
            }
            
            try context.save()
            print("successfully saved artists")
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct APIArtist: Decodable, Hashable {
    var id: Int64
    var name: String
    var normalizedName: String
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    var imageType: String?
}

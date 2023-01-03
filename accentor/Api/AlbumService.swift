//
//  AlbumService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import CoreData

struct AlbumService {
    let apiPath = "albums"
    public static let shared = AlbumService()
    
    func index(context: NSManagedObjectContext) {
        AbstractService.shared.index(path: apiPath, entityName: "Album", completion: { jsonData in
            print("Inside complettion for albums")
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US")
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            do {
                let albums = try decoder.decode([APIAlbum].self, from: jsonData)
                DispatchQueue.main.async {
                    self.saveAlbums(context: context, albums: albums)
                }
            } catch {
                print("Error decoding albums", error.localizedDescription)
            }
        })
    }
    
    private func saveAlbums(context: NSManagedObjectContext, albums: [APIAlbum]) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        albums.forEach { (album) in
            let entity: Album!
            
            let fetchAlbum: NSFetchRequest<Album> = Album.fetchRequest()
            fetchAlbum.predicate = NSPredicate(format: "id == %ld", album.id)
            
            let results = try? context.fetch(fetchAlbum)
            if results?.count == 0 {
                entity = Album(context: context)
                entity.id = album.id
            } else {
                entity = results?.first
            }
            entity.title = album.title
            entity.normalizedTitle = album.normalizedTitle
            entity.releaseDate = album.releaseDate
            entity.reviewComment = album.reviewComment
            entity.edition = album.edition
            entity.editionDescription = album.editionDescription
            entity.image = album.image
            entity.image100 = album.image100
            entity.image250 = album.image250
            entity.image500 = album.image500
            entity.fetchedAt = Date()
            
            entity.albumArtists?.forEach({ item in
                let albumArtist = item as! AlbumArtist
                context.delete(albumArtist)
            })
            
            if (album.albumArtists  != []) {
                album.albumArtists.forEach { (albumArtist) in
                    let nestedEntity = AlbumArtist(context: context)
                    nestedEntity.album = entity
                    nestedEntity.artistId = albumArtist.artistId
                    nestedEntity.name = albumArtist.name
                    nestedEntity.normalizedName = albumArtist.normalizedName
                    nestedEntity.order = albumArtist.order
                    nestedEntity.separator = albumArtist.separator
                    
                    // Look for the artist and re-create the association
                    let fetchArtist: NSFetchRequest<Artist> = Artist.fetchRequest()
                    fetchArtist.predicate = NSPredicate(format: "id == %ld", albumArtist.artistId)
                    let artist = try? context.fetch(fetchArtist).first
                    nestedEntity.artist = artist
                }
            
            }
        }
        
        do {
            try context.save();
            print("successfully saved albums")
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct APIAlbumArtist: Decodable, Hashable {
    var artistId: Int64
    var name: String
    var normalizedName: String
    var order: Int16
    var separator: String?
}

struct APIAlbum: Decodable, Hashable {

    enum CodingKeys: String, CodingKey {
        case id, title, normalizedTitle, edition, editionDescription, reviewComment, image, image100, image250, image500, albumArtists
        
        // Map the JSON key "release" to the Swift property name "releaseDate"
        case releaseDate = "release"
    }

    var id: Int64
    var title: String
    var normalizedTitle: String
    var releaseDate: Date?
    var reviewComment: String?
    
    // Edition
    var edition: Date?
    var editionDescription: String?
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    
    // Album artists
    var albumArtists: [APIAlbumArtist] = []
}

// NOTE: The dateFormatter does not seem to recognize `01-01-0000` as a valid date
// We write our own init, so that any error decoding this date are ignored
extension APIAlbum {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        normalizedTitle = try container.decode(String.self, forKey: .normalizedTitle)
        reviewComment = try? container.decode(String.self, forKey: .reviewComment)
        releaseDate = try? container.decode(Date.self, forKey: .releaseDate)
        edition = try? container.decode(Date.self, forKey: .edition)
        editionDescription = try? container.decode(String.self, forKey: .editionDescription)
        image = try? container.decode(String.self, forKey: .image)
        image100 = try? container.decode(String.self, forKey: .image100)
        image250 = try? container.decode(String.self, forKey: .image250)
        image500 = try? container.decode(String.self, forKey: .image500)
    
        // The api always returns and empty array, so we can call `try!` here.
        albumArtists = try container.decode([APIAlbumArtist].self, forKey: .albumArtists)
    }
}

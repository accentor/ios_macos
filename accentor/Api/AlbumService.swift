//
//  AlbumService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation

struct AlbumService {
    static let apiPath = "albums"
    let database: AppDatabase
    
    init(_ db: AppDatabase) {
        self.database = db
    }
    
    func index() async {
        let startLoading = Date()
        var count = 0
        var buffer: [APIAlbum] = []

        do {
            for try await data in AbstractService.Index(path: AlbumService.apiPath) {
                do {
                    let albums = try AbstractService.jsonDecoder.decode([APIAlbum].self, from: data)
                    buffer.append(contentsOf: albums)
                    
                } catch {
                    print("Error decoding albums", error)
                }
                
                count += 1
                if count >= 5 {
                    await saveAlbums(apiAlbums: buffer)
                    buffer = []
                    count = 0
                }
            }
            
            await saveAlbums(apiAlbums: buffer)
            try! await database.deleteOldAlbums(startLoading)
        } catch ApiError.unauthorized {
            Task { try await AuthService(database).logout() }
        } catch {
            print("Encountered an error fetching data", error)
        }
    }
    
    private func saveAlbums(apiAlbums: [APIAlbum]) async {
        let fetchedAt = Date()
        var albums: [Album] = []
        var albumArtists: [AlbumArtist] = []
        
        apiAlbums.forEach { apiAlbum in
            albums.append(Album(apiAlbum: apiAlbum, fetchedAt: fetchedAt))
            albumArtists.append(contentsOf: apiAlbum.albumArtists.map({ apiAlbumArtist in
                AlbumArtist(apiAlbumArtist: apiAlbumArtist, albumId: apiAlbum.id, fetchedAt: fetchedAt)
            }))
        }
        do {
            try await database.saveAlbums(albums: albums, albumArtists: albumArtists)
        } catch {
            print(error)
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
        case id, title, normalizedTitle, edition, editionDescription, reviewComment, image, image100, image250, image500, imageType, albumArtists, createdAt, updatedAt, release
    }

    var id: Int64
    var title: String
    var normalizedTitle: String
    var release: Date?
    var reviewComment: String?
    
    // Edition
    var edition: Date?
    var editionDescription: String?
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    var imageType: String?
    
    // Album artists
    var albumArtists: [APIAlbumArtist] = []
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
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
        release = try? container.decode(Date.self, forKey: .release)
        edition = try? container.decode(Date.self, forKey: .edition)
        editionDescription = try? container.decode(String.self, forKey: .editionDescription)
        image = try? container.decode(String.self, forKey: .image)
        image100 = try? container.decode(String.self, forKey: .image100)
        image250 = try? container.decode(String.self, forKey: .image250)
        image500 = try? container.decode(String.self, forKey: .image500)
        imageType = try? container.decode(String.self, forKey: .imageType)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    
        // The api always returns and empty array, so we can call `try` here.
        albumArtists = try container.decode([APIAlbumArtist].self, forKey: .albumArtists)
    }
}

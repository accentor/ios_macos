//
//  ArtistService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 28/12/2022.
//

import Foundation

struct ArtistService {
    static let apiPath = "artists"
    let database: AppDatabase

    init(_ db: AppDatabase) {
        self.database = db
    }

    func index() async {
        let startLoading = Date()
        var count = 0
        var buffer: [APIArtist] = []
        
        do {
            for try await data in AbstractService.Index(path: ArtistService.apiPath) {
                do {
                    let artists = try AbstractService.jsonDecoder.decode([APIArtist].self, from: data)
                    buffer.append(contentsOf: artists)
                    
                } catch {
                    print("Error decoding artists", error)
                }
                
                count += 1
                if count >= 5 {
                    await saveArtists(apiArtists: buffer)
                    buffer = []
                    count = 0
                }
            }
            
            await saveArtists(apiArtists: buffer)
            try! await database.deleteOldArtists(startLoading)
        }  catch ApiError.unauthorized {
            Task { try await AuthService(database).logout() }
        } catch {
            print("Encountered an error fetching data", error)
        }
    }
    
    private func saveArtists(apiArtists: [APIArtist]) async {
        let fetchedAt = Date()
        var artists: [Artist] = []
        apiArtists.forEach { apiArtist in
            artists.append(Artist(apiArtist: apiArtist, fetchedAt: fetchedAt))
        }
        
        do {
            try await database.saveArtists(artists)
        } catch {
            print(error)
        }
    }
}

struct APIArtist: Decodable, Hashable {
    var id: Int64
    var name: String
    var normalizedName: String
    var reviewComment: String?
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    var imageType: String?
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
}

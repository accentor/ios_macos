//
//  ArtistService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 28/12/2022.
//

import Foundation

struct ArtistService {
    let apiPath = "artists"
    let database: AppDatabase

    init(_ db: AppDatabase) {
        self.database = db
    }

    func index() async {
        let startLoading = Date()
        
        await AbstractService.shared.index(path: apiPath, completion: { jsonData in
            do {
                let artists = try AbstractService.jsonDecoder.decode([APIArtist].self, from: jsonData)
                await self.saveArtists(apiArtists: artists)
            } catch {
                print("Error decoding artists", error)
            }
        })
        
        try! await database.deleteOldArtists(startLoading)
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

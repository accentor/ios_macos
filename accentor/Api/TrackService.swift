//
//  TrackService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import Sentry

struct TrackService {
    static let apiPath = "tracks";
    let database: AppDatabase
    
    init(_ db: AppDatabase) {
        self.database = db
    }
    
    func index() async {
        let startLoading = Date()
        var count = 0
        var buffer: [APITrack] = []
        
        do {
            for try await data in AbstractService.Index(path: TrackService.apiPath) {
                do {
                    let tracks = try AbstractService.jsonDecoder.decode([APITrack].self, from: data)
                    buffer.append(contentsOf: tracks)
                } catch {
                    SentrySDK.capture(error: error)
                    print("Error decoding tracks", error)
                }
                
                count += 1
                if count >= 5 {
                    await self.saveTracks(apiTracks: buffer)
                    buffer = []
                    count = 0
                }
            }
            
            await self.saveTracks(apiTracks: buffer)
            try! await database.deleteOldTracks(startLoading)
        }  catch ApiError.unauthorized {
            Task { try await AuthService(AppDatabase.shared).logout() }
        } catch {
            SentrySDK.capture(error: error)
            print("Encountered an error fetching data", error)
        }
    }
    
    private func saveTracks(apiTracks: [APITrack]) async {
        let fetchedAt = Date()
        var tracks: [Track] = []
        var trackArtists: [TrackArtist] = []
        
        apiTracks.forEach { apiTrack in
            tracks.append(Track(apiTrack: apiTrack, fetchedAt: fetchedAt))
            trackArtists.append(contentsOf: apiTrack.trackArtists.map({ apiTrackArtist in
                TrackArtist(apiTrackArtist: apiTrackArtist, trackId: apiTrack.id)
            }))
        }
        
        do {
            try await database.saveTracks(tracks: tracks, trackArtists: trackArtists)
        } catch {
            SentrySDK.capture(error: error)
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
    var reviewComment: String?
    
    // Audio properties
    var bitrate: Int16?
    var locationId: Int64?
    var length: Int16?
    var codecId: Int64?
    
    // Track artists
    var trackArtists: [APITrackArtist] = []
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
}

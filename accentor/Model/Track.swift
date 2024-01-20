//
//  Track.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB

struct Track: Identifiable, Equatable, Codable, FetchableRecord, PersistableRecord {
    // Generic properties
    var id: Int64
    var createdAt: Date
    var updatedAt: Date
    var fetchedAt: Date
    var reviewComment: String?
    
    // Basic properties
    var title: String
    var normalizedTitle: String
    var number: Int16
    var albumId: Int64

    // Audio file properties
    var codecId: Int64?
    var length: Int16?
    var bitrate: Int16?
    var locationId: Int64?
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let normalizedTitle = Column(CodingKeys.normalizedTitle)
    }
}

extension Track {
    init(apiTrack: APITrack, fetchedAt: Date = Date()) {
        self.id = apiTrack.id
        self.createdAt = apiTrack.createdAt
        self.updatedAt = apiTrack.updatedAt
        self.fetchedAt = fetchedAt
        self.reviewComment = apiTrack.reviewComment
        self.title = apiTrack.title
        self.normalizedTitle = apiTrack.normalizedTitle
        self.number = apiTrack.number
        self.albumId = apiTrack.albumId
        self.codecId = apiTrack.codecId
        self.length = apiTrack.length
        self.bitrate = apiTrack.bitrate
        self.locationId = apiTrack.locationId
    }
}

extension Track {
    static let albumFK = ForeignKey(["albumId"], to: ["id"])
    static let album = belongsTo(Album.self, using: albumFK)
    static let trackArtists = hasMany(TrackArtist.self)
    static let plays = hasMany(Play.self, using: Play.trackFK)
}

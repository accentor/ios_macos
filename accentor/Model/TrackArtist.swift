//
//  TrackArtist.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB

struct TrackArtist: Identifiable, Equatable {
    var id: Int64?
    var artistId: Int64
    var trackId: Int64
    var name: String
    var normalizedName: String
    var order: Int16
    var role: String
    var hidden: Bool
}

extension TrackArtist: Codable, FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension TrackArtist {
    static let track = belongsTo(Track.self)
    static let artistFK = ForeignKey(["artistId"], to: ["id"])
    static let artist = belongsTo(Artist.self, using: artistFK)
}

extension TrackArtist {
    init(apiTrackArtist: APITrackArtist, trackId: Int64) {
        self.artistId = apiTrackArtist.artistId
        self.trackId = trackId
        self.name = apiTrackArtist.name
        self.normalizedName = apiTrackArtist.normalizedName
        self.order = apiTrackArtist.order
        self.role = apiTrackArtist.role
        self.hidden = apiTrackArtist.hidden
    }
}


extension TrackArtist {
    static func constructTrackArtistText(_ trackArtists: [TrackArtist]?) -> String {
        guard let trackArtists = trackArtists else { return "" }
                    
        return trackArtists.sorted { ta1, ta2 in
            ta1.order < ta2.order
        }.map { ta in
            ta.name
        }.joined(separator: " / ")
    }
}

//
//  ArtistPlayStat.swift
//  accentor
//
//  Created by Robbe Van Petegem on 20/01/2024.
//

import Foundation
import GRDB

struct ArtistPlayStat: Equatable, Decodable, FetchableRecord, TableRecord {
    var artistId: Int64
    var playCount: Int
    var lastPlayed: Date
    
    enum Columns {
        static let artistId = Column(CodingKeys.artistId)
        static let playCount = Column(CodingKeys.playCount)
        static let lastPlayed = Column(CodingKeys.lastPlayed)
    }
}

extension ArtistPlayStat {
    static let artistFK = ForeignKey(["artistId"], to: ["id"])
    static let artist = belongsTo(Artist.self)
}

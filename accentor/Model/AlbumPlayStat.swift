//
//  AlbumPlayStat.swift
//  accentor
//
//  Created by Robbe Van Petegem on 20/01/2024.
//

import Foundation
import GRDB

struct AlbumPlayStat: Equatable, Decodable, FetchableRecord, TableRecord {
    var albumId: Int64
    var playCount: Int
    var lastPlayed: Date
    
    enum Columns {
        static let albumId = Column(CodingKeys.albumId)
        static let playCount = Column(CodingKeys.playCount)
        static let lastPlayed = Column(CodingKeys.lastPlayed)
    }
}

extension AlbumPlayStat {
    static let albumFK = ForeignKey(["albumId"], to: ["id"])
    static let album = belongsTo(Album.self)
}

//
//  Play.swift
//  accentor
//
//  Created by Robbe Van Petegem on 20/01/2024.
//

import Foundation
import GRDB

struct Play: Identifiable, Equatable, Codable, Hashable, FetchableRecord, PersistableRecord {
    var id: Int64
    var fetchedAt: Date
    var userId: Int64
    var trackId: Int64
    var playedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, fetchedAt, userId, trackId, playedAt
    }
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let trackId = Column(CodingKeys.trackId)
        static let playedAt = Column(CodingKeys.playedAt)
    }
}

extension Play {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int64.self, forKey: .id)
        self.playedAt = try container.decode(Date.self, forKey: .playedAt)
        self.trackId = try container.decode(Int64.self, forKey: .trackId)
        self.userId = try container.decode(Int64.self, forKey: .userId)
        self.fetchedAt = Date()
    }
}

extension Play {
    static let trackFK = ForeignKey(["trackId"], to: ["id"])
    static let track = belongsTo(Track.self, using: trackFK)
}

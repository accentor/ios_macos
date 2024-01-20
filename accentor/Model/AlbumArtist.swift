//
//  AlbumArtist.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB

struct AlbumArtist: Identifiable, Equatable {
    var id: Int64?
    var fetchedAt: Date
    var artistId: Int64
    var albumId: Int64
    var name: String
    var normalizedName: String
    var order: Int16
    var separator: String?
}

extension AlbumArtist: Codable, FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension AlbumArtist {
    static let album = belongsTo(Album.self)
    static let artistFK = ForeignKey(["artistId"], to: ["id"])
    static let artist = belongsTo(Artist.self, using: artistFK)
}

extension AlbumArtist {
    init(apiAlbumArtist: APIAlbumArtist, albumId: Int64, fetchedAt: Date = Date()) {
        self.fetchedAt = fetchedAt
        self.artistId = apiAlbumArtist.artistId
        self.albumId = albumId
        self.name = apiAlbumArtist.name
        self.normalizedName = apiAlbumArtist.normalizedName
        self.order = apiAlbumArtist.order
        self.separator = apiAlbumArtist.separator
    }
}

extension AlbumArtist {
    static func constructAlbumArtistText(_ albumArtists: [AlbumArtist]?) -> String {
        guard let albumArtists = albumArtists else { return "Various Artists" }
                    
        let sorted = albumArtists.sorted { aa1, aa2 in
            aa1.order < aa2.order
        }
                                            
        return sorted.reduce("", { acc, cur in
            return "\(acc)\(cur.name)\(cur.separator ?? "")"
        })
    }
}

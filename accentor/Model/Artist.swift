//
//  Artist.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB

struct Artist: Identifiable, Equatable, Codable, Hashable, FetchableRecord, PersistableRecord {
    // Generic properties
    var id: Int64
    var createdAt: Date
    var updatedAt: Date
    var fetchedAt: Date = Date()
    var reviewComment: String?
    
    // Basic properties
    var name: String
    var normalizedName: String
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    var imageType: String?

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let normalizedName = Column(CodingKeys.normalizedName)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension Artist {
    init(apiArtist: APIArtist, fetchedAt: Date = Date()) {
        self.id = apiArtist.id
        self.name = apiArtist.name
        self.createdAt = apiArtist.createdAt
        self.updatedAt = apiArtist.updatedAt
        self.fetchedAt = fetchedAt
        self.reviewComment = apiArtist.reviewComment
        self.name = apiArtist.name
        self.normalizedName = apiArtist.normalizedName
        self.image = apiArtist.image
        self.image100 = apiArtist.image100
        self.image250 = apiArtist.image250
        self.image500 = apiArtist.image
        self.imageType = apiArtist.imageType
    }
}

extension Artist {
    static let artistFK = ForeignKey(["artistId"], to: ["id"])
    static let albumArtists = hasMany(AlbumArtist.self, using: artistFK)
    static let albums = hasMany(Album.self, through: albumArtists, using: AlbumArtist.album)
    static let trackArtists = hasMany(TrackArtist.self, using: artistFK)
    static let tracks = hasMany(Track.self, through: trackArtists, using: TrackArtist.track)
    static let playStat = hasOne(ArtistPlayStat.self, using: ArtistPlayStat.artistFK)
}

extension DerivableRequest<Artist> {
    /// Filters albums by title or normalizedTitle
    func filter(name: String?) -> Self {
        guard let query = name, !query.isEmpty else { return all() }

        return filter(Artist.Columns.name.like("%\(query)%") || Artist.Columns.normalizedName.like("%\(query)%"))
    }
    
    /// Order by recently played
    func orderByRecentlyPlayed() -> Self {
        let statAlias = TableAlias()
        return joining(required: Artist.playStat.aliased(statAlias)).order(statAlias[ArtistPlayStat.Columns.lastPlayed.desc])
    }
}

//
//  Album.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB

struct Album: Identifiable, Equatable, Codable, FetchableRecord, PersistableRecord {
    // Generic properties
    var id: Int64
    var createdAt: Date
    var updatedAt: Date
    var fetchedAt: Date
    var reviewComment: String?
    
    // Basic properties
    var title: String
    var normalizedTitle: String
    var release: Date?

    // Edition
    var edition: Date?
    var editionDescription: String?
    
    // Image
    var image: String?
    var image100: String?
    var image250: String?
    var image500: String?
    var imageType: String?
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let normalizedTitle = Column(CodingKeys.normalizedTitle)
        static let release = Column(CodingKeys.release)
        static let edition = Column(CodingKeys.edition)
        static let editionDescription = Column(CodingKeys.editionDescription)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension Album {
    init(apiAlbum: APIAlbum, fetchedAt: Date = Date()) {
        self.id = apiAlbum.id
        self.createdAt = apiAlbum.createdAt
        self.updatedAt = apiAlbum.updatedAt
        self.fetchedAt = fetchedAt
        self.title = apiAlbum.title
        self.normalizedTitle = apiAlbum.normalizedTitle
        self.release = apiAlbum.release
        self.edition = apiAlbum.edition
        self.editionDescription = apiAlbum.editionDescription
        self.image = apiAlbum.image
        self.image100 = apiAlbum.image100
        self.image250 = apiAlbum.image250
        self.image500 = apiAlbum.image
        self.imageType = apiAlbum.imageType
    }
}

extension Album {
    static let tracks = hasMany(Track.self, using: Track.albumFK)
    static let albumArtists = hasMany(AlbumArtist.self)
    static let plays = hasMany(Play.self, through: tracks, using: Track.plays)
    static let playStat = hasOne(AlbumPlayStat.self, using: AlbumPlayStat.albumFK)
    
    var tracks: QueryInterfaceRequest<Track> {
        request(for: Album.tracks)
   }
}

extension DerivableRequest<Album> {
    /// Filters albums by title or normalizedTitle
    func filter(title: String?) -> Self {
        guard let query = title, !query.isEmpty else { return all() }

        return filter(Album.Columns.title.like("%\(query)%") || Album.Columns.normalizedTitle.like("%\(query)%"))
    }
    
    /// Order albums by release
    //    ORDER BY release DESC,
    //             normalized_title ASC,
    //             edition ASC,
    //             edition_description ASC,
    //             id ASC
    func orderByRelease(newestFirst: Bool = false) -> Self {
        order(newestFirst ? Album.Columns.release.desc : Album.Columns.release.asc, Album.Columns.normalizedTitle, Album.Columns.edition, Album.Columns.editionDescription, Album.Columns.id)
    }
    
    /// Order albums by normalizedTitle
    // ORDER BY normalized_title ASC, release ASC, edition ASC, edition_description ASC, id ASC
    func orderByTitle() -> Self {
        order(Album.Columns.normalizedTitle, Album.Columns.release, Album.Columns.edition, Album.Columns.editionDescription, Album.Columns.id)
    }
    
    /// Order by recently played
    func orderByRecentlyPlayed() -> Self {
        let statAlias = TableAlias()
        return joining(required: Album.playStat.aliased(statAlias)).order(statAlias[AlbumPlayStat.Columns.lastPlayed.desc])
    }
}

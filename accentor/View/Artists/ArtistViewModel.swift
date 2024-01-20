//
//  ArtistViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 17/01/2024.
//

import Combine
import GRDB

final class ArtistViewModel: ObservableObject {
    struct ArtistInfo: Decodable, FetchableRecord {
        var artist: Artist
        var tracks: [Track]
        var albums: [Album]
    }

    @Published private(set) var artistInfo: ArtistInfo?
    
    private var observationCancellable: AnyCancellable?
    private let database: AppDatabase
    
    init(database: AppDatabase, id: Album.ID) {
        self.database = database
        self.observationCancellable = ValueObservation
            .tracking(Artist.filter(key: id).including(all: Artist.tracks.order(Track.Columns.normalizedTitle)).including(all: Artist.albums.all().orderByRelease()).asRequest(of: ArtistInfo.self).fetchOne)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] artistInfo in
                    self?.artistInfo = artistInfo
                })
    }
}

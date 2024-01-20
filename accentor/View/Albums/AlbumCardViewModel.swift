//
//  AlbumCardViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 16/01/2024.
//

import Foundation
import Combine
import GRDB

final class AlbumCardViewModel: ObservableObject {
    struct AlbumInfo: Decodable, FetchableRecord {
        var album: Album
        var albumArtists: [AlbumArtist]
    }
    @Published private(set) var albumInfo: AlbumInfo?
    
    private var observationCancellable: AnyCancellable?
    private let database: AppDatabase
    
    init(database: AppDatabase, id: Album.ID) {
        self.database = database
        self.observationCancellable = ValueObservation
            .tracking(Album.filter(key: id).including(all: Album.albumArtists).asRequest(of: AlbumInfo.self).fetchOne)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albumInfo in
                    self?.albumInfo = albumInfo
                })
    }
    
    func queueAlbum() async {
        guard let album = albumInfo?.album else { return }

        let tracks = try! await self.database.reader.read { db in
            try album.tracks.order(Column("number")).fetchAll(db)
        }
        PlayQueue.shared.addTracksToQueue(tracks: tracks, replace: true)
    }
}
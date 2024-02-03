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
    @Published var isHovered: Bool = false
    
    private var observationCancellable: AnyCancellable?
    private let database: AppDatabase
    private let player: Player
    
    init(database: AppDatabase, player: Player, id: Album.ID) {
        self.database = database
        self.player = player
        self.observationCancellable = ValueObservation
            .tracking(Album.filter(key: id).including(all: Album.albumArtists).asRequest(of: AlbumInfo.self).fetchOne)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albumInfo in
                    self?.albumInfo = albumInfo
                })
    }
    
    func playAlbum() {
        albumInfo?.album.queue(database: database, playQueue: player.playQueue)
    }
    
    func shuffleAlbum() {
        albumInfo?.album.queue(.shuffle, database: database, playQueue: player.playQueue)
    }
    
    func playNext() {
        albumInfo?.album.queue(.playNext, database: database, playQueue: player.playQueue)
    }
    
    func playLast() {
        albumInfo?.album.queue(.playLast, database: database, playQueue: player.playQueue)
    }
}

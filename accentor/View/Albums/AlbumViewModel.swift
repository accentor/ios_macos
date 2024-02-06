//
//  AlbumViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 24/01/2024.
//

import Foundation
import GRDB
import Combine

final class AlbumViewModel: ObservableObject {
    struct TrackInfo: Decodable {
        var track: Track
        var trackArtists: [TrackArtist]
    }
    struct AlbumInfo: Decodable, FetchableRecord {
        var album: Album
        var albumArtists: [AlbumArtist]
        var tracks: [TrackInfo]
    }
    
    @Published private(set) var albumInfo: AlbumInfo?
    
    var tracksStats: String {
        guard let tracks = albumInfo?.tracks else { return "" }
        
        // We force our counter to be an `Int64`
        // This avoids an overflow when an album is more than 32768 sec (±9h)
        let totalLength = tracks.reduce(Int64(0)) { partialResult, trackInfo in
            partialResult + Int64(trackInfo.track.length ?? 0)
        }
        
        let hours = totalLength / 60 / 60
        let minutes = (totalLength / 60) % 60
        let time = hours > 0 ? "\(hours) hours, \(minutes) minutes" : "\(minutes) minutes"
        return "\(tracks.count) tracks, \(time)"
    }
    
    private var observationCancellable: AnyCancellable?
    private let database: AppDatabase
    private let player: Player
    
    init(database: AppDatabase, player: Player, id: Album.ID) {
        self.database = database
        self.player = player
        self.observationCancellable = ValueObservation
            .tracking(Album.filter(key: id).including(all: Album.tracks.order(Track.Columns.number).including(all: Track.trackArtists)).including(all: Album.albumArtists).asRequest(of: AlbumInfo.self).fetchOne)
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

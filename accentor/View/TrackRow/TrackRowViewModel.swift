//
//  TrackRowViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 02/02/2024.
//

import Foundation
import GRDB
import Combine

final class TrackRowViewModel: ObservableObject {
    let track: Track
    let trackArtists: [TrackArtist]
    private let database: AppDatabase
    private let player: Player
    
    init(database: AppDatabase, player: Player, track: Track, trackArtists: [TrackArtist]) {
        self.database = database
        self.player = player
        self.track = track
        self.trackArtists = trackArtists
    }
    
    func playTrack() {
        player.playQueue.addTrackToQueue(track: track, replace: true)
    }
    
    func playNext() {
        player.playQueue.addTrackToQueue(track: track, position: .next, replace: false)
    }
    
    func playLast() {
        player.playQueue.addTrackToQueue(track: track, position: .last, replace: false)
    }
}

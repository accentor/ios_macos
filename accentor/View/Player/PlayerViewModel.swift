//
//  PlayerViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 16/01/2024.
//

import Foundation
import GRDB
import Combine

final class PlayerViewModel: ObservableObject {
    @Published private(set) var trackInfo: Player.TrackInfo?
    @Published private(set) var playerState: Player.PlayerState
    let player: Player
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(player: Player) {
        self.player = player
        self.trackInfo = player.playingTrackInfo
        self.playerState = player.playerState

        player.$playingTrackInfo.sink { [weak self] trackInfo in
            self?.trackInfo = trackInfo
        }.store(in: &cancellables)
        player.$playerState.sink { [weak self] state in
            self?.playerState = state
        }.store(in: &cancellables)
    }
}

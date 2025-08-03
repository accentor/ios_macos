//
//  Player.swift
//  accentor
//
//  Created by Robbe Van Petegem on 16/01/2024.
//

import Foundation
import Combine
import AVFAudio
import AVFoundation
import MediaPlayer
import GRDB
import Sentry
import OSLog

class Player: ObservableObject {  // Possible values of `playerState`
    // The raw values match those of `MPNowPlayingPlaybackState`
    enum PlayerState: UInt {
        case stopped = 3
        case playing = 1
        case paused = 2
        
        var isPlaying: Bool {
            switch self {
            case .playing: true
            default: false
            }
        }
    }
    
    struct TrackInfo: Decodable, FetchableRecord {
        var track: Track
        var album: Album?
        var trackArtists: [TrackArtist]
        var albumArtists: [AlbumArtist]
    }

    @Published private(set) var playerState: PlayerState = .stopped {
        didSet { self.handlePlaybackChange() }
    }
    private var playingItem: PlayQueueItem? {
        didSet { self.fetchPlayingTrackInfo() }
    }
    @Published private(set) var playingTrackInfo: TrackInfo?

    let playQueue: PlayQueue
    private let database: AppDatabase
    private let playService: PlayService
    private var player: AVPlayer = AVPlayer()
    private var statusObserver: NSObjectProtocol!
    private var cancellables: Set<AnyCancellable> = []

    static func empty() -> Player {
        return Player(queue: PlayQueue.empty(), database: AppDatabase.empty())
    }
    
    static let shared: Player = Player(queue: PlayQueue.shared, database: AppDatabase.shared)

    init(queue: PlayQueue, database: AppDatabase) {
        self.playQueue = queue
        self.database = database
        self.playService = PlayService(database)
        player.allowsExternalPlayback = true

        setupCommandCenter()
        
        // Listen for changes in the playQueue
        playQueue.$currentIndex.sink { [weak self] newIndex in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.setPlayingTrack(currentItem: self.playQueue.currentItem)
            }
        }.store(in: &cancellables)
        
        statusObserver = player.observe(\.currentItem?.status, options: .initial) {
            [unowned self] _, _ in self.handlePlaybackChange()
        }
        
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Playing info
extension Player {
    var canPlay: Bool {
        get { return playQueue.queue.count > 0 }
    }
    var canGoNext: Bool {
        get { return playQueue.currentIndex < (playQueue.queue.count - 1) }
    }
    var canGoPrev: Bool {
        get { return playQueue.currentIndex > 0 }
    }
}

// MARK: - Controls
extension Player {
    func play() {
        // Don't start if there is no track
        // guard currentTrack != nil else { return }

        do {
            #if os(iOS)
            // Configure and activate the AVAudioSession
            // This is only available on iOS
            try AVAudioSession.sharedInstance().setCategory(.playback)

            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            
            self.player.play()
            DispatchQueue.main.async {
                self.playerState = .playing
            }
        }
        catch {
            SentrySDK.capture(error: error)
            Logger.player.error("Error while playing \(error)")
        }
    }
    
    func pause() {
        self.player.pause()
        self.playerState = .paused
    }
    
    func stop() {
        self.player.pause()
        self.player.seek(to: CMTime(value: 0, timescale: 1))
        self.playerState = .stopped
    }
    
    func next() {
        self.playQueue.setIndex(playQueue.currentIndex + 1)
    }

    func prev() {
        self.playQueue.setIndex(playQueue.currentIndex - 1)
    }
    
    func togglePlaying() {
        guard playQueue.currentIndex != -1 else {
            playQueue.setIndex(0)
            return
        }

        switch self.playerState  {
        case .playing: self.pause()
        case .paused: self.play()
        case .stopped: self.play()
        }
    }
}

// MARK: - Playing callbacks

extension Player {
    @objc func playerDidFinishPlaying() {
        guard let playingTrackId = self.playingTrackInfo?.track.id else { return }

        Task { await playService.create(trackId: playingTrackId) }
        self.next()
    }

    @MainActor
    private func setPlayingTrack(currentItem: PlayQueueItem?) {
        self.stop()
        self.playingItem = currentItem

        guard let item = currentItem else {
            self.playingTrackInfo = nil
            return
        }
        
        self.handlePlayerItemChange()
        self.player.replaceCurrentItem(with: item.playerItem())
        self.player.automaticallyWaitsToMinimizeStalling = false
        self.play()
    }
}

// MARK: - Now playing info
extension Player {
    private func fetchPlayingTrackInfo() {
        guard let trackId = playingItem?.trackId else { return }

        ValueObservation
            .tracking(Track.filter(key: trackId).including(all: Track.trackArtists).including(optional: Track.album.forKey("album").including(all: Album.albumArtists.forKey("albumArtists"))).asRequest(of: TrackInfo.self).fetchOne)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] trackInfo in
                    self?.playingTrackInfo = trackInfo
                    self?.handlePlaybackChange()
                }).store(in: &cancellables)
    }
    
    private func handlePlayerItemChange() {
        guard playerState != .stopped else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfoCenter.nowPlayingInfo = constructNowPlaying(nil)
    }
    
    private func handlePlaybackChange() {
        MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState(rawValue: playerState.rawValue)!
        
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = constructNowPlaying(nowPlayingInfoCenter.nowPlayingInfo)
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(currentItem.currentTime().seconds)
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        // We start this in a separate thread, so we return from this function
        Task { await self.setNowPlayingArtwork() }
    }
    
    private func constructNowPlaying(_ nowPlayingInfo: [String: Any]?) -> [String: Any] {
        var nowPlayingInfo = nowPlayingInfo ?? [String: Any]()
        
        // Always set type to music
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPMediaType.music.rawValue
        
        guard let currentTrackInfo = self.playingTrackInfo else { return nowPlayingInfo }
        
        // Set track info
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrackInfo.track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = TrackArtist.constructTrackArtistText(currentTrackInfo.trackArtists)
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = AlbumArtist.constructAlbumArtistText(currentTrackInfo.albumArtists)
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = currentTrackInfo.album?.title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentTrackInfo.track.length
        
        return nowPlayingInfo
    }
    
    private func setNowPlayingArtwork() async {
        guard let album = self.playingTrackInfo?.album else { return }

        guard album.image250 != nil, let imageURL = URL(string: album.image250!) else { return }
        let imageRepository = ImageRepository()

        guard let image = await imageRepository.getImage(imageURL: imageURL) else { return }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = constructNowPlaying(nowPlayingInfoCenter.nowPlayingInfo)

        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }

        // If the player is playing, we update current time, so the notification doesn't get confused
        if let currentItem = player.currentItem, currentItem.status == .readyToPlay {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(currentItem.currentTime().seconds)
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
    }
}

// MARK: - Command center
extension Player {
    enum RemoteCommand {
        case play
        case pause
        case stop
        case togglePausePlay
        case nextTrack
        case previousTrack
    }

    private func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.play, event: $0) }
        commandCenter.pauseCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.pause, event: $0) }
        commandCenter.stopCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.stop, event: $0) }
        commandCenter.togglePlayPauseCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.togglePausePlay, event: $0) }
        commandCenter.nextTrackCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.nextTrack, event: $0) }
        commandCenter.previousTrackCommand.addTarget { self.handleRemoteCommand(command: RemoteCommand.previousTrack, event: $0) }
        
    }
    
    private func handleRemoteCommand(command: RemoteCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch command {
        case .pause: pause()
        case .play: play()
        case .stop: stop()
        case .togglePausePlay: togglePlaying()
        case .nextTrack: next()
        case .previousTrack: prev()
        }
        
        return .success
    }
}

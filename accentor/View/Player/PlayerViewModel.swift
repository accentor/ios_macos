//
//  PlayerViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import AVFAudio
import AVFoundation
import Combine
import MediaPlayer

class PlayerViewModel: NSObject, ObservableObject {
    // Possible values of `playerState`
    // The raw values match those of `MPNowPlayingPlaybackState`
    enum PlayerState: UInt {
        case stopped = 3
        case playing = 1
        case paused = 2
    }
    
    /// This property is published, so that changes in this state triggers a reload in the view
    /// The view should use the computed `playing` property,
    @Published private var playerState: PlayerState = .stopped {
        didSet { self.handlePlaybackChange() }
    }

    @Published var playingTrack: Track?
    @Published var playQueue: PlayQueue = PlayQueue.shared

    var playing: Bool {
        get { return self.playerState == .playing }
    }
    var canPlay: Bool {
        get { return playQueue.queue.count > 0 }
    }
    var canGoNext: Bool {
        get { return playQueue.currentIndex < (playQueue.queue.count - 1) }
    }
    var canGoPrev: Bool {
        get { return playQueue.currentIndex > 0 }
    }
    
    // The PlayerViewModel is a singleton class, since we only want one player
    // Otherwise our track would restart when the view was updated
    public static let shared = PlayerViewModel()

    private var player: AVPlayer = AVPlayer()
    private var statusObserver: NSObjectProtocol!
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        // Mark player to allow external playback
        player.allowsExternalPlayback = true
        setupCommandCenter()

        playQueue.$currentIndex.sink { [weak self] newIndex in
            guard let self = self else { return }
            
            // Run in main thread, so we can access the new computed value
            DispatchQueue.main.async {
                self.setPlayingTrack(queueItem: self.playQueue.currentTrack)
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
    
    // Player
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
            print("Error while playing")
            print(error)
        }
    }
    
    @objc func playerDidFinishPlaying() {
        PlayService.shared.create(trackId: self.playingTrack!.id) { data, error in
            print(data, error)
        }
        self.next()
    }

    @MainActor
    private func setPlayingTrack(queueItem: PlayQueueItem?) {
        self.playingTrack = queueItem?.track

        guard self.playingTrack != nil else { self.stop(); return }

        self.handlePlayerItemChange()
        self.player.replaceCurrentItem(with: queueItem?.playerItem())
        player.automaticallyWaitsToMinimizeStalling = false
        self.play()
    }

    // MARK: Now playing info
    private func handlePlayerItemChange() {
        guard playerState != .stopped else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfoCenter.nowPlayingInfo = constructNowPlaying()

    }
    
    private func handlePlaybackChange() {
        MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState(rawValue: playerState.rawValue)!
        
        guard let currentItem = player.currentItem, currentItem.status == .readyToPlay else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? constructNowPlaying()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(currentItem.currentTime().seconds)
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        // We start this in a separate thread, so we return from this function
        Task { await self.setNowPlayingArtwork() }
    }
    
    private func constructNowPlaying() -> [String: Any] {
        var nowPlayingInfo = [String: Any]()
        
        // Always set type to music
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPMediaType.music.rawValue
        
        guard let currentTrack = self.playingTrack else { return nowPlayingInfo }
        
        // Set track info
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentTrack.trackArtistsText
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = currentTrack.album?.albumArtistsText
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = currentTrack.album?.title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentTrack.length
        
        return nowPlayingInfo
    }
    
    private func setNowPlayingArtwork() async {
        guard let currentTrack = self.playingTrack else { return }
        guard currentTrack.album?.image250 != nil, let imageURL = URL(string: currentTrack.album!.image250!) else { return }
        let imageRepository = ImageRepository()
        
        guard let image = await imageRepository.getImage(imageURL: imageURL) else { return }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? constructNowPlaying()
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }

        // If the player is playing, we update current time, so the notification doesn't get confused
        if let currentItem = player.currentItem, currentItem.status == .readyToPlay {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(currentItem.currentTime().seconds)
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
    }
    
    // MARK: Remote commands
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

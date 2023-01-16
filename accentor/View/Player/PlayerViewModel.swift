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

class PlayerViewModel: NSObject, ObservableObject {
    @Published var playing: Bool = false
    @Published var playingTrack: Track?
    @Published var playQueue: PlayQueue = PlayQueue.shared
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
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        playQueue.$currentIndex.sink { [weak self] newIndex in
            guard let self = self else { return }
            
            // Run in main thread, so we can access the new computed value
            DispatchQueue.main.async {
                self.setPlayingTrack(queueItem: self.playQueue.currentTrack)
            }
        }.store(in: &cancellables)
        
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

        if self.playing {
            self.pause()
        } else {
            self.play()
        }
    }
    
    func pause() {
        self.player.pause()
        self.playing = false
    }
    
    func stop() {
        self.player.pause()
        self.player.seek(to: CMTime(value: 0, timescale: 1))
        self.playing = false
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
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback
            )

            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            
            self.player.play()
            DispatchQueue.main.async { self.playing = true }
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

    private func setPlayingTrack(queueItem: PlayQueueItem?) {
        self.playingTrack = queueItem?.track

        guard self.playingTrack != nil else { self.stop(); return }

        self.player.replaceCurrentItem(with: queueItem?.playerItem())
        player.automaticallyWaitsToMinimizeStalling = false
        self.play()
    }
}

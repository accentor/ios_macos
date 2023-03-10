//
//  PlayQueue.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/11/2022.
//

import Foundation
import AVFoundation
import CoreData

class PlayQueue: ObservableObject {
    @Published private(set) var queue: [PlayQueueItem] = []
    @Published private(set) var currentIndex: Int = -1
    
    // PlayQueue is a singleton class, since we only ever want one queue in our whole app
    public static let shared = PlayQueue()
    
    // Computed props
    var currentTrack: PlayQueueItem? {
        get {
            guard currentIndex != -1 else { return nil }

            return queue[currentIndex]
        }
    }
    
    // Manage index
    func setIndex(_ newIndex: Int) {
        // If currentIndex is out of bounds, we set to -1
        guard newIndex < queue.count && newIndex > -1 else {
            currentIndex = -1
            return
        }

        currentIndex = newIndex
    }
    
    // Managing queue
    func addTrackToQueue(track: Track, position: QueueItemPosition = .last, replace: Bool = false) {
        if replace { self.clearQueue() }

        switch position {
        case .last: queue.append(PlayQueueItem(track: track))
        case .next: queue.insert(PlayQueueItem(track: track), at: min(queue.endIndex, 1))
        }
        
        // Start playing if this is the first track was added
        if (queue.count == 1) { setIndex(0) }
    }
    
    func addAlbumToQueue(album: Album, position: QueueItemPosition = .last, replace: Bool = false) {
        if replace { self.clearQueue() }
        
        let mapped = album.tracks.map { PlayQueueItem(track: $0) }
        
        switch position {
        case .last: queue.insert(contentsOf: mapped, at: queue.endIndex)
        case .next: queue.insert(contentsOf: mapped, at: min(queue.endIndex, 1))
        }
        
        // Start playing if the queue was empty
        if (queue.count == album.tracks.count) { setIndex(0) }
        
    }
    
    func removeItem(index: Int) {
        // Stop playing if we are removing the currentItem
        if self.currentIndex == index {
            self.currentIndex = -1
        }
        
        queue.remove(at: index)
    }
    
    private func clearQueue() {
        currentIndex = -1
        queue = []
    }
}

enum QueueItemPosition: Equatable {
    case next
    case last
}

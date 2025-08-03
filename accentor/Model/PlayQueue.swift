//
//  PlayQueue.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/11/2022.
//

import Foundation
import CoreData
import OSLog

class PlayQueue: ObservableObject {
    enum QueueItemPosition: Equatable {
        case next
        case last
    }

    @Published private(set) var queue: [PlayQueueItem] = []
    @Published private(set) var currentIndex: Int = -1
    
    
    // PlayQueue is a singleton class, since we only ever want one queue in our whole app
    public static let shared = PlayQueue()
    
    // Allow empty playQueue for swiftUI previews
    public static func empty() -> PlayQueue {
        return PlayQueue()
    }
    
    // Computed props
    var currentItem: PlayQueueItem? {
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
        addTracksToQueue(tracks: [track], position: position, replace: replace)
    }
    
    func addTracksToQueue(tracks: [Track], position: QueueItemPosition = .last, replace: Bool = false) {
        if replace { self.clearQueue() }
        
        let mapped = tracks.map { PlayQueueItem(trackId: $0.id) }
        
        switch position {
        case .last: queue.insert(contentsOf: mapped, at: queue.endIndex)
        case .next: queue.insert(contentsOf: mapped, at: min(queue.endIndex, 1))
        }
        
        // Start playing if the queue was empty
        if (queue.count == tracks.count) { setIndex(0) }
        
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


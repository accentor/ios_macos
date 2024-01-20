//
//  HomeViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 16/01/2024.
//

import Foundation
import Combine
import GRDB

final class HomeViewModel: ObservableObject {
    @Published private(set) var recentlyReleasedAlbums: [Album] = []
    @Published private(set) var recentlyAddedAlbums: [Album] = []
    @Published private(set) var recentlyPlayedAlbums: [Album] = []
    @Published private(set) var onThisDay: [Album] = []
    @Published private(set) var recentlyAddedArtists: [Artist] = []
    @Published private(set) var recentlyPlayedArtists: [Artist] = []
    
    private let database: AppDatabase
    private var cancellables: Set<AnyCancellable> = []
    
    init(database: AppDatabase) {
        self.database = database
        
        self.fetchRecentlyPlayedAlbums()
        self.fetchRecentlyPlayedArtists()
        self.fetchRecentlyAddedAlbums()
        self.fetchRecentlyReleased()
        self.fetchOnThisDay()
        self.fetchRecentlyAddedArtists()
    }
    
    private func fetchRecentlyPlayedAlbums() {
        ValueObservation
            .tracking(
                region: Album.all(), Play.all(),
                fetch: { db in try Album.all().orderByRecentlyPlayed().fetchAll(db) }
            )
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.recentlyPlayedAlbums = albums
                }).store(in: &cancellables)
    }
    
    private func fetchRecentlyPlayedArtists() {
        ValueObservation
            .tracking(
                region: Artist.all(), Play.all(),
                fetch: { db in try Artist.all().orderByRecentlyPlayed().fetchAll(db) }
            )
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] artists in
                    self?.recentlyPlayedArtists = artists
                }).store(in: &cancellables)
    }
    
    private func fetchRecentlyReleased() {
        ValueObservation.tracking(Album.all().orderByRelease(newestFirst: true).fetchAll)
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.recentlyReleasedAlbums = albums
                }).store(in: &cancellables)
    }
    
    private func fetchRecentlyAddedAlbums() {
        ValueObservation
            .tracking(Album.order(Album.Columns.createdAt.desc).fetchAll)
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.recentlyAddedAlbums = albums
                }).store(in: &cancellables)
    }
    
    private func fetchRecentlyAddedArtists() {
        ValueObservation
            .tracking(Artist.order(Artist.Columns.createdAt.desc).fetchAll)
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] artists in
                    self?.recentlyAddedArtists = artists
                }).store(in: &cancellables)
    }
    
    private func fetchOnThisDay() {
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        ValueObservation
            .tracking(Album.filter(Column("release").like("%\(df.string(from: Date()))%")).order(Column("release").desc).fetchAll)
            .publisher(in: database.reader, scheduling: .async(onQueue: DispatchQueue.main))
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.onThisDay = albums
                }).store(in: &cancellables)
    }
    
}

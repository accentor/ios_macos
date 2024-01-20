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
    @Published private(set) var onThisDay: [Album] = []
    
    private var cancellables: Set<AnyCancellable> = []
   
    private let database: AppDatabase
    
    init(database: AppDatabase) {
        self.database = database
        ValueObservation
            .tracking(Album.order(Column("release").desc).fetchAll)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.recentlyReleasedAlbums = albums
                }).store(in: &cancellables)

        ValueObservation
            .tracking(Album.order(Column("createdAt").desc).fetchAll)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.recentlyAddedAlbums = albums
                }).store(in: &cancellables)
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        ValueObservation
            .tracking(Album.filter(Column("release").like("%\(df.string(from: Date()))%")).order(Column("release").desc).fetchAll)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albums in
                    self?.onThisDay = albums
                }).store(in: &cancellables)
    }
}

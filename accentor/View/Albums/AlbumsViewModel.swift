//
//  AlbumsViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 16/01/2024.
//

import Foundation
import GRDB
import Combine

final class AlbumsViewModel: ObservableObject {
    @Published private(set) var albumIds: [Album.ID] = []
    @Published var searchTerm: String = "" {
        didSet {
            // Run async, so we don't block the actual input
            DispatchQueue.main.async {
                self.setupValueObservation()
            }
        }
    }
    
    private var observationCancellable: AnyCancellable?
    private let database: AppDatabase
    
    init(database: AppDatabase) {
        self.database = database
        setupValueObservation()
    }
    
    private func setupValueObservation() {
        self.observationCancellable = ValueObservation
            .tracking(Album.all().filter(title: searchTerm).orderByTitle().selectPrimaryKey(as: Int64.self).fetchAll)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] albumIds in
                    self?.albumIds = albumIds
                })
    }
}

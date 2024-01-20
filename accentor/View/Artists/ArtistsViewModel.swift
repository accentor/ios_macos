//
//  ArtistsViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 17/01/2024.
//

import Foundation
import Combine
import GRDB

final class ArtistsViewModel: ObservableObject {
    @Published private(set) var artists: [Artist] = []
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
    
    func setupValueObservation() {
        self.observationCancellable = ValueObservation
            .tracking(Artist.all().filter(name: searchTerm).order(Artist.Columns.normalizedName).fetchAll)
            .publisher(in: database.reader, scheduling: .immediate)
            .sink(
                receiveCompletion: { _ in /* ignore error */ },
                receiveValue: { [weak self] artists in
                    self?.artists = artists
                })
    }
}

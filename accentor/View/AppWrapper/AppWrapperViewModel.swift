//
//  AppWrapperViewModel.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import Combine
import GRDB
import Foundation

final class AppWrapperViewModel: ObservableObject {
    enum Route: Hashable {
        case albums
        case artists
        case home
        case tracks
    }

    // NOTE: This will never actually be `nil`, but this is needed to build on iOS
    // Since this initializer isn't available on iOS: <https://developer.apple.com/documentation/swiftui/list/init(selection:content:)-590zm>
    @Published var selectedRoute: Route? = .home
    private let database: AppDatabase

    init(database: AppDatabase) {
        self.database = database
    }

    func setDefaultSettings() {
        // Always set this key, to apply new default settings
        UserDefaults.standard.set(DefaultSettings.codecConversionId, forKey: "codecConversionId")
    }
    
    func fetchAll() async {
        async let albums: () = AlbumService(database).index()
        async let artists: () = ArtistService(database).index()
        async let tracks: () = TrackService(database).index()
        _ = await [albums, artists, tracks]
    }
}



//
//  accentorApp.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI
import Sentry

@main
struct accentorApp: App {
    @AppStorage("userId") private var userId: Int?
    
    init() {
        SentrySDK.start { options in
            // NOTE: We read the DSN setting from the `SENTRY_DSN` environment variable
            #if DEBUG
            options.debug = true // Enabling debug when first installing is always helpful
            #endif
        }
    }

    var body: some Scene {
        WindowGroup {
            if (userId != nil) {
                AppWrapperView()
            } else {
                LoginView()
            }
        }
        .commands {
            CommandMenu("Data") {
                Button(action: {
                    Task {
                        async let albums: () = AlbumService(AppDatabase.shared).index()
                        async let artists: () = ArtistService(AppDatabase.shared).index()
                        async let plays: () = PlayService(AppDatabase.shared).index()
                        async let tracks: () = TrackService(AppDatabase.shared).index()
                        _ = await [albums, artists, plays, tracks]
                    }

                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "last_sync_finished")
                }, label: {
                    Text("Refresh")
                })
            }
            CommandMenu("Account") {
                Button(action: {
                    Task {
                        try await AuthService(AppDatabase.shared).logout()
                    }
                }, label: {
                    Text("Sign out")
                })
            }

        }
        .environment(\.appDatabase, .shared).environment(\.player, .shared)
    }
}

// MARK: - Give SwiftUI access to the database & player
//
// Define a new environment key that grants access to an AppDatabase.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .empty() }
}

private struct PlayerKey: EnvironmentKey {
    static var defaultValue: Player { .empty() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
    
    var player: Player {
        get { self[PlayerKey.self] }
        set { self[PlayerKey.self] = newValue }
    }
}

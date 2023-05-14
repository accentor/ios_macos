//
//  accentorApp.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI

@main
struct accentorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandMenu("Data") {
                Button(action: {
                    AlbumService.shared.index(context: persistenceController.container.viewContext)
                    ArtistService.shared.index(context: persistenceController.container.viewContext)
                    TrackService.shared.index(context: persistenceController.container.viewContext)
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "last_sync_finished")
                }, label: {
                    Text("Refresh")
                })
            }
        }
    }
}

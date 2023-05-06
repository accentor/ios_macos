//
//  AppWrapper.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI

enum Route: Hashable {
    case albums
    case artists
    case home
    case tracks
}

struct AppWrapper: View {
    @State private var selectedRoute: Route?
    @StateObject var viewModel = AppWrapperViewModel()
    @Environment(\.managedObjectContext) var context
    
    func onAppear() {
        print("Starting on appear")
        viewModel.setDefaultSettings()
        
        // Configure URLCache
        URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space

//        viewModel.fetchAll(context: context)
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedRoute) {
                Section {
                    NavigationLink(value: Route.home, label: { Label("Home", systemImage: "music.note.house") })
                }
                Section("Library") {
                    NavigationLink(value: Route.albums, label: { Label("Albums", systemImage: "square.stack") })
                    NavigationLink(value: Route.artists, label: { Label("Artists", systemImage: "music.mic") })
                    NavigationLink(value: Route.tracks, label: { Label("Tracks", systemImage: "music.note") })
                }
            }.navigationTitle("Accentor")
        } detail: {
            ZStack(alignment: .bottom) {
                switch self.selectedRoute {
                case .albums:
                    Albums()
                case .artists:
                    Artists()
                case .home:
                    Home()
                case .tracks:
                    Tracks()
                default:
                    Home()
                    
                }
                Player()
            }
        }.onAppear(perform: onAppear)
            .refreshable {
                viewModel.fetchAll(context: context)
            }
    }
}

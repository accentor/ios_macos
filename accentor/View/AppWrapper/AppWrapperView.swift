//
//  AppWrapper.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI
import GRDBQuery

struct AppWrapperView: View {
    @EnvironmentStateObject private var viewModel: AppWrapperViewModel
    
    init() {
        _viewModel = EnvironmentStateObject {
            AppWrapperViewModel(database: $0.appDatabase)
        }
    }
    
    func onAppear() {
        viewModel.setDefaultSettings()
        
        // Configure URLCache
        URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
        
        Task { await viewModel.fetchAll() }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedRoute) {
                Section {
                    NavigationLink(value: AppWrapperViewModel.Route.home, label: { Label("Home", systemImage: "music.note.house") })
                }
                Section("Library") {
                    NavigationLink(value: AppWrapperViewModel.Route.albums, label: { Label("Albums", systemImage: "square.stack") })
                    NavigationLink(value: AppWrapperViewModel.Route.artists, label: { Label("Artists", systemImage: "music.mic") })
//                    NavigationLink(value: AppWrapperViewModel.Route.tracks, label: { Label("Tracks", systemImage: "music.note") })
                }
            }.navigationTitle("Accentor")
        } detail: {
            ZStack(alignment: .bottom) {
                switch viewModel.selectedRoute {
                case .albums:
                    AlbumsView().padding([.bottom], 65)
                case .artists:
                    ArtistsView().padding([.bottom], 65)
                case .home:
                    HomeView().padding([.bottom], 65)
//                case .tracks:
//                    Tracks().padding([.bottom], 65)
                default:
                    HomeView()
                    
                }
                PlayerView()
            }
        }.onAppear(perform: onAppear)
            .refreshable {
                Task { await viewModel.fetchAll() }
            }
    }
}

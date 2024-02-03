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
            NavigationStack(path: $viewModel.detailsPath) {
                HStack {
                    switch viewModel.selectedRoute {
                    case .albums:
                        AlbumsView()
                    case .artists:
                        ArtistsView()
                    case .home:
                        HomeView()
                        //                case .tracks:
                        //                    Tracks()
                    default:
                        HomeView()
                    }
                }.navigationDestination(for: Album.self) { album in
                    AlbumView(id: album.id).background(.white).overlay(alignment: .bottom, content: { PlayerView() })
                }.navigationDestination(for: Artist.self) { artist in
                    ArtistView(id: artist.id).background(.white).overlay(alignment: .bottom, content: { PlayerView() })
                }.overlay(alignment: .bottom, content: { PlayerView() })
            }.background(.white)
        }.onAppear(perform: viewModel.handleAppear)
            .refreshable {
                Task { await viewModel.fetchAll() }
            }
    }
}

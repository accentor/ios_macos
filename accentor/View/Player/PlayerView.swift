//
//  PlayerView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import AVFAudio
import GRDBQuery

struct PlayerView: View {
    @EnvironmentStateObject private var viewModel: PlayerViewModel
    
    init() {
        _viewModel = EnvironmentStateObject {
            PlayerViewModel(player: $0.player)
        }
    }

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color.white.opacity(0.0)).frame(height: 65)
                        #if os(iOS)
                        .background(UIBlur())
                        #else
                        .background(NSBlur())
                        #endif
            HStack {
                Button(action: {}) {
                    HStack {
                        CachedImage(imageURL: viewModel.trackInfo?.album?.image250) {
                            ZStack {
                                Rectangle().fill(.gray)
                                Image(systemName: "music.note").font(.largeTitle)
                            }
                        /// NOTE: We use `.id()` to force the view to re-initialize.
                        /// This ensure the image changes when the currentTrack changes
                        }.id(viewModel.trackInfo?.album?.image250)
                         .frame(width: 45, height: 45).shadow(radius: 6, x: 0, y: 3).padding(.leading)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.trackInfo?.track.title ?? "").lineLimit(1).truncationMode(.tail)
                            Text(TrackArtist.constructTrackArtistText(viewModel.trackInfo?.trackArtists)).lineLimit(1).truncationMode(.tail)
                        }.padding(.leading, 5)
                        
                        Spacer()
                    }.foregroundColor(.black)
                }
                #if os(macOS)
                Button(action: viewModel.player.prev) {
                    Image(systemName: "backward.end.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.player.canGoPrev ? .black : .gray.opacity(0.75)).disabled(!viewModel.player.canGoPrev)
                #endif
                
                Button(action: viewModel.player.togglePlaying) {
                    Image(systemName: viewModel.playerState.isPlaying ? "pause.fill" : "play.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.player.canPlay ? .black : .gray.opacity(0.75))
                    .padding(.horizontal, 2).disabled(!viewModel.player.canPlay)
                 .keyboardShortcut(.space, modifiers: [])
                
                Button(action: viewModel.player.next) {
                    Image(systemName: "forward.end.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.player.canPlay ? .black : .gray.opacity(0.75)).padding(.trailing, 20).disabled(!viewModel.player.canGoNext)
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
        }
        
    }
}

#if os(iOS)
struct UIBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemChromeMaterial
        
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
#endif

#if os(macOS)
struct NSBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material = NSVisualEffectView.Material.headerView
    let blendingMode: NSVisualEffectView.BlendingMode = NSVisualEffectView.BlendingMode.withinWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
#endif


#Preview {
    PlayerView().environment(\.appDatabase, .empty()).environment(\.player, .empty())
}

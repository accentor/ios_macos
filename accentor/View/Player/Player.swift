//
//  Player.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import AVFAudio
import CachedAsyncImage

struct Player: View {
    @State private var showQueue = false
//    @FetchRequest(entity: QueueItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \QueueItem.index, ascending: true)]) var queueItems : FetchedResults<QueueItem>
    @StateObject var viewModel = PlayerViewModel.shared
    @StateObject var playQueue = PlayQueue.shared
    
    func toggleShowQueue() {
        showQueue.toggle()
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
                        if (viewModel.playQueue.currentTrack != nil && viewModel.playQueue.currentTrack?.track.album?.image250 != nil) {
                            CachedAsyncImage(url: URL(string: viewModel.playQueue.currentTrack!.track.album!.image250!)) { phase in
                                if let image = phase.image {
                                    image.resizable().frame(width: 45, height: 45).shadow(radius: 6, x: 0, y: 3).padding(.leading)
                                } else {
                                    ZStack {
                                        Rectangle().fill(.gray)
                                        Image(systemName: "music.note").font(.largeTitle)
                                    }.frame(width: 45, height: 45).shadow(radius: 6, x: 0, y: 3).padding(.leading)
                                }
                            }
                        } else {
                            ZStack {
                                Rectangle().fill(Color.gray)
                                Image(systemName: "music.note").font(.largeTitle)
                            }.frame(width: 45, height: 45).shadow(radius: 6, x: 0, y: 3).padding(.leading)
                        }
                        VStack(alignment: .leading) {
                            Text(viewModel.playQueue.currentTrack?.track.title ?? "").lineLimit(1).truncationMode(.tail)
                            Text(viewModel.playQueue.currentTrack?.track.trackArtistsText ?? "").lineLimit(1).truncationMode(.tail)
                        }.padding(.leading, 5)
                        
                        Spacer()
                    }.foregroundColor(.black)
                }
                #if os(macOS)
                Button(action: viewModel.prev) {
                    Image(systemName: "backward.end.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.canGoPrev ? .black : .gray.opacity(0.75)).disabled(!viewModel.canGoPrev)
                #endif
                
                Button(action: viewModel.togglePlaying) {
                    Image(systemName: viewModel.playing ? "pause.fill" : "play.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.canPlay ? .black : .gray.opacity(0.75))
                 .padding(.horizontal, 2).disabled(!viewModel.canPlay)
                 .keyboardShortcut(.space, modifiers: [])   
                
                Button(action: viewModel.next) {
                    Image(systemName: "forward.end.fill").font(.title3).padding(12)
                }.foregroundColor(viewModel.canPlay ? .black : .gray.opacity(0.75)).padding(.trailing, 20).disabled(!viewModel.canGoNext)
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


//struct Player_Previews: PreviewProvider {
//    static var previews: some View {
//        Player()
//    }
//}

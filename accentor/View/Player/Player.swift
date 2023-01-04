//
//  Player.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import AVFAudio

struct Player: View {
    @State private var showQueue = false
//    @FetchRequest(entity: QueueItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \QueueItem.index, ascending: true)]) var queueItems : FetchedResults<QueueItem>
    @StateObject var viewModel = PlayerViewModel()
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
                            AsyncImage(url: URL(string: viewModel.playQueue.currentTrack!.track.album!.image250!)) { phase in
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

                        Text(viewModel.playQueue.currentTrack?.track.title ?? "").padding(.leading, 10)
                        Spacer()
                    }
                }.buttonStyle(PlainButtonStyle())
                #if os(macOS)
                    Button(action: viewModel.prev) {
                        Image(systemName: "backward.fill").font(.title3)
                    }.buttonStyle(PlainButtonStyle())
                #endif
                Button(action: viewModel.togglePlaying) {
                    Image(systemName: viewModel.playing ? "pause.fill" : "play.fill").font(.title3)
                }.buttonStyle(PlainButtonStyle()).padding(.horizontal)
                Button(action: viewModel.next) {
                    Image(systemName: "forward.fill").font(.title3)
                }.buttonStyle(PlainButtonStyle()).padding(.trailing, 30)
            }
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

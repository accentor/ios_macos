//
//  TrackRow.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import SwiftUI
import CoreData

struct TrackRow: View {
    @Environment(\.managedObjectContext) var context
    var track: Track
    
    func addToPlayQueue() {
        PlayQueue.shared.addTrackToQueue(track: track)
    }

    var body: some View {
        Button(action: addToPlayQueue) {
            HStack(alignment: .center) {
                Text(track.title ?? "").frame(maxWidth: .infinity, alignment: .leading)
                Text(String(format: "%0d:%02d", track.length / 60, track.length % 60)).frame(alignment: .trailing)
            }
        }
        
    }
}

//struct TrackRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRow()
//    }
//}

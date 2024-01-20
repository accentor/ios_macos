//
//  PlayQueueItem.swift
//  accentor
//
//  Created by Robbe Van Petegem on 29/12/2022.
//

import Foundation
import AVFoundation

class PlayQueueItem {
    @Published private(set) var trackId: Track.ID
    var cachePath: String
    var cached: Bool = false
    
    init(trackId: Track.ID) {
        self.trackId = trackId
        let codecConversionId = UserDefaults.standard.string(forKey: "codecConversionId")!
        var fileCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        // We store audio under `audio__trackId__codecConversionId`
        fileCachePath.appendPathComponent("audio__\(trackId)__\(codecConversionId)", isDirectory: false)
        self.cachePath = fileCachePath.path
        self.cached = FileManager.default.fileExists(atPath: self.cachePath)
        
        print("\(cachePath) was \(cached ? "" : "not ")cached")
    }
    
    func playerItem() -> CachingPlayerItem {
        var playerItem: CachingPlayerItem
        if (cached) {
            let data = try? Data(contentsOf: URL(filePath: self.cachePath))
            if (data != nil) {
                playerItem =  CachingPlayerItem(data: data!, mimeType: "audio/mpeg", fileExtension: "mp3")
                playerItem.delegate = self
                return playerItem
            }
        }
        playerItem = CachingPlayerItem(url: audioURL(), customFileExtension: "mp3")
        playerItem.delegate = self
        return playerItem
    }
    
    private func audioURL() -> URL {
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/tracks/\(trackId)/audio"
        
        components.queryItems = [
            URLQueryItem(name: "codec_conversion_id", value: UserDefaults.standard.string(forKey: "codecConversionId")!),
            URLQueryItem(name: "secret", value: UserDefaults.standard.string(forKey: "secret")!),
            URLQueryItem(name: "device_id", value: UserDefaults.standard.string(forKey: "deviceId")!)
        ]
        
        return components.url!
    }
}

extension PlayQueueItem: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("finished downlaoding and storing in \(self.cachePath)")
        FileManager.default.createFile(atPath: self.cachePath, contents: data)
    }
}

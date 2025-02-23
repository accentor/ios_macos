//
//  AudioService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import Sentry

class AudioService {
    public static let shared = AudioService()
    
    public func loadAudio(id: Int64, completion: @escaping (URL?, Error?) -> Void) {
        let codecConversionId = UserDefaults.standard.string(forKey: "codecConversionId")!
        var fileCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        // We store audio under `audio__trackId__codecConversionId`
        fileCachePath.appendPathComponent("audio__\(id)__\(codecConversionId)", isDirectory: false)
        
        
        
        if FileManager.default.fileExists(atPath: fileCachePath.path) {
            print("Found audio file in cache path: \(fileCachePath)")
            completion(fileCachePath, nil)
            return
        }
        
        let trackURL = audioURLFromId(id: id)
        
        
        downloadAudio(url: trackURL, toFile: fileCachePath, completion: { (error) in
            print("Downlaoded audio from \(trackURL) and storing in \(fileCachePath)")
            completion(fileCachePath, error)
        })
    }
    
    private func downloadAudio(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) {
            (tmpURL, response, error) in
            
            guard let tmpURL = tmpURL else {
                completion(error)
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                
                try FileManager.default.copyItem(at: tmpURL, to: file)
                
                completion(nil)
            } catch {
                SentrySDK.capture(error: error)
                completion(error)
            }
        }
        task.resume()
    }
    
    private func audioURLFromId(id: Int64) -> URL {
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/tracks/\(id)/audio"
        
        components.queryItems = [
            URLQueryItem(name: "codec_conversion_id", value: UserDefaults.standard.string(forKey: "codecConversionId")!),
            URLQueryItem(name: "token", value: UserDefaults.standard.string(forKey: "apiToken")!)
        ]
        
        return components.url!
    }
}

//
//  PlayService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 06/11/2022.
//

import Foundation

struct APIPlayBody: Codable {
    let trackId: Int64
    let playedAt: Date
}

struct APIPlayBodyWrapper: Codable {
    let play: APIPlayBody
}


struct PlayService {
    static let apiPath = "plays"
    let database: AppDatabase
    
    init(_ db: AppDatabase) {
        self.database = db
    }
    
    func index() async {
        let startLoading = Date()
        
        await AbstractService.shared.index(path: PlayService.apiPath) { jsonData in
            do {
                let plays = try AbstractService.jsonDecoder.decode([Play].self, from: jsonData)
                try await self.database.savePlays(plays)
            }  catch {
                print("Error decoding or saving plays", error)
            }
        }
        
        try! await database.deleteOldPlays(startLoading)
    }
    
    func create(trackId: Int64) async {
        let body = APIPlayBodyWrapper(play: APIPlayBody(trackId: trackId, playedAt: Date.now))
        let uploadData = try! AbstractService.jsonEncoder.encode(body)
        do {
            let response = try await AbstractService.shared.create(path: PlayService.apiPath, body: uploadData)
            
            let play = try AbstractService.jsonDecoder.decode(Play.self, from: response)
            
            try await self.database.savePlay(play)
        } catch {
            print("Error saving play", error)
        }
        
    }
}

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
        var count = 0
        var buffer: [Play] = []
        do {
            for try await data in AbstractService.Index(path: PlayService.apiPath) {
                do {
                    let plays = try AbstractService.jsonDecoder.decode([Play].self, from: data)
                    buffer.append(contentsOf: plays)
                } catch {
                    print("Error decoding plays", error)
                }
                
                count += 1
                if count >= 5 {
                    try! await self.database.savePlays(buffer)
                    buffer = []
                    count = 0
                }
            }
            
            try! await self.database.savePlays(buffer)
            try! await database.deleteOldPlays(startLoading)
        }  catch ApiError.unauthorized {
            Task { try await AuthService(database).logout() }
        } catch {
            print("Encountered an error fetching data", error)
        }
    }
    
    func create(trackId: Int64) async {
        let body = APIPlayBodyWrapper(play: APIPlayBody(trackId: trackId, playedAt: Date.now))
        let uploadData = try! AbstractService.jsonEncoder.encode(body)
        do {
            let response = try await AbstractService.shared.create(path: PlayService.apiPath, body: uploadData)
            
            let play = try AbstractService.jsonDecoder.decode(Play.self, from: response)
            
            try await self.database.savePlay(play)
        }  catch ApiError.unauthorized {
            Task { try await AuthService(AppDatabase.shared).logout() }
        } catch {
            print("Encountered an error creating play", error)
        }
        
    }
}

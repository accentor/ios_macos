//
//  AuthService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import Sentry
import OSLog

struct APILoginBody: Codable {
    let name: String
    let password: String
    let application: String
}

struct APILoginResponse: Decodable {
    let userId: Int64
    let token: String
}

struct AuthService {
    static let apiPath = "auth_tokens"
    let database: AppDatabase
    
    init(_ db: AppDatabase) {
        self.database = db
    }

    func login(username: String, password: String) async throws {
        let body = APILoginBody(name: username, password: password, application: AbstractService.application)
        let uploadData = try! AbstractService.jsonEncoder.encode(body)
        
        let response = try await AbstractService.shared.create(path: AuthService.apiPath, body: uploadData)


        let data = try AbstractService.jsonDecoder.decode(APILoginResponse.self, from: response)
        
        UserDefaults.standard.set(data.token, forKey: "apiToken")
        UserDefaults.standard.set(data.userId, forKey: "userId")
    }
    
    func logout() async throws {
        UserDefaults.standard.removeObject(forKey: "apiToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        do {
            try await database.clearDatabase()
        } catch {
            SentrySDK.capture(error: error)
            Logger.api.error("Could not clear database \(error)")
        }
        
        let fileCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let files = try FileManager.default.contentsOfDirectory(at: fileCachePath, includingPropertiesForKeys: [])
        Logger.api.info("Removing \(files.count) from audio cache")
        do {
            try files.forEach { path in
                try FileManager.default.removeItem(atPath: path.path())
            }
        } catch {
            SentrySDK.capture(error: error)
            Logger.api.error("Could not remove track \(error)")
        }
    }
}

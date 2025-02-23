//
//  AuthService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation

struct APILoginBody: Codable {
    let name: String
    let password: String
    let application: String
}

struct APILoginResponse: Decodable {
    let userId: Int64
    let deviceId: String
    let secret: String
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
        
        UserDefaults.standard.set(data.deviceId, forKey: "deviceId")
        UserDefaults.standard.set(data.secret, forKey: "secret")
        UserDefaults.standard.set(data.userId, forKey: "userId")
    }
    
    func logout() async throws {
        UserDefaults.standard.removeObject(forKey: "devicedId")
        UserDefaults.standard.removeObject(forKey: "secret")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        do {
            try await database.clearDatabase()
        } catch {
            print(error)
        }
        
        let fileCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let files = try FileManager.default.contentsOfDirectory(at: fileCachePath, includingPropertiesForKeys: [])
        print("Removing \(files.count) from audio cache")
        do {
            try files.forEach { path in
                try FileManager.default.removeItem(atPath: path.path())
            }
        } catch {
            print(error)
        }
    }
}

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
}

struct APILoginResponse: Decodable {
    let userId: Int64
    let deviceId: String
    let secret: String
}

struct AuthService {
    static let apiPath = "auth_tokens"
    public static let shared = AuthService()

    func login(username: String, password: String) async throws {
        let body = APILoginBody(name: username, password: password)
        let uploadData = try! AbstractService.jsonEncoder.encode(body)
        
        let response = try await AbstractService.shared.create(path: AuthService.apiPath, body: uploadData)


        let data = try AbstractService.jsonDecoder.decode(APILoginResponse.self, from: response)
        
        UserDefaults.standard.set(data.deviceId, forKey: "deviceId")
        UserDefaults.standard.set(data.secret, forKey: "secret")
        UserDefaults.standard.set(data.userId, forKey: "userId")
    }
}

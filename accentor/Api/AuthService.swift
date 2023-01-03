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
    public static let shared = AuthService()

    func login(username: String, password: String, completion: @escaping (APILoginResponse?, Error?) -> Void) {
        let body = APILoginBody(name: username, password: password)
        guard let uploadData = try? JSONEncoder().encode(body) else {
            return
        }
        
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/auth_tokens"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Accentor for iOS/macOS", forHTTPHeaderField: "user-agent")

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            }
            
            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                completion(nil, error)
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let parsedData = try? decoder.decode(APILoginResponse.self, from: data)
                completion(parsedData, nil)
            }
        }
        task.resume()
    }
}

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

struct APIPlay: Decodable {
    let id: Int64
    let trackId: Int64
    let userId: Int64
    let playedAt: Date
}

struct PlayService {
    public static let shared = PlayService()
    
    func create(trackId: Int64, completion: @escaping (APIPlay?, Error?) -> Void) {
        let body = APIPlayBodyWrapper(play: APIPlayBody(trackId: trackId, playedAt: Date.now))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        guard let uploadData = try? encoder.encode(body) else {
            return
        }
        print(body)
        
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/plays"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "deviceId")!, forHTTPHeaderField: "x-device-id")
        request.addValue(UserDefaults.standard.string(forKey: "secret")!, forHTTPHeaderField: "x-secret")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            }
            
            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                completion(nil, error)
            }
            
            if let data = data {
                print(data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let parsedData = try! decoder.decode(APIPlay.self, from: data)
                completion(parsedData, nil)
            }
        }
        
        task.resume()
    }
}

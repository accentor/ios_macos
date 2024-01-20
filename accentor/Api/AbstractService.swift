//
//  AbstractService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import CoreData

enum ApiError: Error {
    case unknown(String)
}


class AbstractService {
    public static let shared = AbstractService()
    
    func index(path: String, completion: @escaping (Data) async -> ()) async {
        var currentPage = 1
        var totalPages = 1
        
        while (currentPage <= totalPages) {
            do {
                let (data, total) = try await self.fetchPage(page: currentPage, path: path)
                totalPages = total
                await completion(data)
            } catch {
                print("Error fetching data", error)
            }
            
            currentPage = currentPage + 1
        }
    }
    
    private func fetchPage(page: Int, path: String) async throws -> (Data, Int) {
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/" + path
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        var request = URLRequest(url: components.url!)
        request.addValue(UserDefaults.standard.string(forKey: "deviceId")!, forHTTPHeaderField: "x-device-id")
        request.addValue(UserDefaults.standard.string(forKey: "secret")!, forHTTPHeaderField: "x-secret")
        
        let session = URLSession(configuration: .default)
        // TODO: Handle errors in requests
        let (data, res) = try await session.data(for: request)
        let response = res as! HTTPURLResponse
        
        if response.statusCode != 200 {
            // TODO: Be smarter about the possible status codes
            print("Error in API")
            throw ApiError.unknown("Error in api \(response)")
        }

        let totalPages = Int(response.value(forHTTPHeaderField: "x-total-pages")!) ?? 0
        
        return (data, totalPages)
    }
    
    static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = dateTimeFormatter.date(from: string) ?? dateFormatter.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        })
        return decoder
    }
    
    static var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}

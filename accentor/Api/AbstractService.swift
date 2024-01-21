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
    struct Index: AsyncSequence {
        typealias AsyncIterator = IndexIterator
        typealias Element = Data
        
        let path: String

        struct IndexIterator: AsyncIteratorProtocol {
            let path: String
            var currentPage = 1


            mutating func next() async -> Data? {
                guard !Task.isCancelled else {
                     return nil
                 }

                let data = try! await self.fetchPage()

                guard !data.isEmpty else {
                    return nil
                }
                
                currentPage += 1
                return data
            }
            
            private func fetchPage() async throws -> Data {
                var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
                components.path = "/api/" + path
                
                components.queryItems = [
                    URLQueryItem(name: "page", value: String(currentPage))
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
                
                return data
            }
        }

        func makeAsyncIterator() -> IndexIterator {
            return IndexIterator(path: path)
        }
    }

    public static let shared = AbstractService()
    
    func create(path: String, body: Data) async throws -> (Data) {
        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/" + path
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "deviceId")!, forHTTPHeaderField: "x-device-id")
        request.addValue(UserDefaults.standard.string(forKey: "secret")!, forHTTPHeaderField: "x-secret")
        
        let session = URLSession(configuration: .default)
        let (data, res) = try await session.upload(for: request, from: body)

        let response = res as! HTTPURLResponse
        
        if !(200...299).contains(response.statusCode) {
            // TODO: Be smarter about the possible status codes
            print("Error in API")
            throw ApiError.unknown("Error in api \(response)")
        }

        return data
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
    
    static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateTimeFormatter)
        return encoder
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

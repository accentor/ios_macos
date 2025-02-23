//
//  AbstractService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import CoreData

enum ApiError: Error {
    case unauthorized
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
            var totalPages = 1


            mutating func next() async throws -> Data? {
                guard !Task.isCancelled else {
                     return nil
                }
                guard currentPage <= totalPages else {
                    return nil
                }

                let (data, response) = try await self.fetchPage()
                totalPages = Int(response.value(forHTTPHeaderField: "x-total-pages")!) ?? 0
                
                currentPage += 1
                return data
            }
            
            private func fetchPage() async throws -> (Data, HTTPURLResponse) {
                var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
                components.path = "/api/" + path
                
                components.queryItems = [
                    URLQueryItem(name: "page", value: String(currentPage))
                ]
                
                var request = URLRequest(url: components.url!)
                request.addValue("Bearer \(UserDefaults.standard.string(forKey: "apiToken")!)", forHTTPHeaderField: "Authorization")
                request.setValue(AbstractService.userAgent, forHTTPHeaderField: "user-agent")
                
                let session = URLSession(configuration: .default)
                // TODO: Handle errors in requests
                let (data, res) = try await session.data(for: request)
                let response = res as! HTTPURLResponse
                
                guard (200...299).contains(response.statusCode) else {
                    // TODO: Be smarter about the possible status codes
                    print("Error in API")
                    switch response.statusCode {
                    case 401: throw ApiError.unauthorized
                    default: throw ApiError.unknown("Error in api \(response)")
                    }
                }
                
                return (data, response)
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
        if let apiToken = UserDefaults.standard.string(forKey: "apiToken") {
            request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(AbstractService.userAgent, forHTTPHeaderField: "user-agent")
        
        let session = URLSession(configuration: .default)
        let (data, res) = try await session.upload(for: request, from: body)

        let response = res as! HTTPURLResponse

        guard (200...299).contains(response.statusCode) else {
            // TODO: Be smarter about the possible status codes
            print("Error in API")
            switch response.statusCode {
            case 401: throw ApiError.unauthorized
            default: throw ApiError.unknown("Error in api \(response)")
            }
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
    
    static var application: String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        #if DEBUG
        let buildNumber = "debug"
        #else
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        #endif

        return "Accentor \(appVersion)-\(buildNumber)"
    }
    
    static var userAgent: String {
        let systemVersion = ProcessInfo().operatingSystemVersionString
        
        #if os(iOS)
        let os = "iOS"
        #elseif os(macOS)
        let os = "macOS"
        #endif
        
        return "\(os) \(systemVersion)"
    }
}

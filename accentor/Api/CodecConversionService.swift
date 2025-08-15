//
//  CodecConversionService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/08/2025.
//

import Foundation
import OSLog
import Sentry

struct CodecConversionService {
    static let apiPath = "codec_conversions"
    let database: AppDatabase
    
    init(_ db: AppDatabase) {
        self.database = db
    }
    
    func index() async {
        let startLoading = Date()
        var count = 0
        var buffer: [CodecConversion] = []
        do {
            for try await data in AbstractService.Index(path: CodecConversionService.apiPath) {
                do {
                    let conversions = try AbstractService.jsonDecoder.decode([CodecConversion].self, from: data)
                    buffer.append(contentsOf: conversions)
                } catch {
                    SentrySDK.capture(error: error)
                    Logger.api.error("Error decoding conversions \(error)")
                }
                
                count += 1
                if count >= 5 {
                    try! await self.database.saveCodecConversions(buffer)
                    buffer = []
                    count = 0
                }
            }
            try! await self.database.saveCodecConversions(buffer)
            try! await database.deleteOldCodecConversions(startLoading)
        } catch ApiError.unauthorized {
            Task { try await AuthService(database).logout() }
        } catch {
            SentrySDK.capture(error: error)
            Logger.api.error("Encountered an error fetching albums \(error)")
        }
    }
}

//
//  CodecConversion.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/08/2025.
//

import Foundation
import GRDB

struct CodecConversion: Identifiable, Equatable, Hashable, Codable, FetchableRecord, PersistableRecord {
//    id name ffmpeg_params resulting_codec_id
    var id: Int64
    var name: String
    var ffmpegParams: String
    var resultingCodecId: Int64
    var fetchedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, ffmpegParams, resultingCodecId, fetchedAt
    }
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }
}

extension CodecConversion {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.ffmpegParams = try container.decode(String.self, forKey: .ffmpegParams)
        self.resultingCodecId = try container.decode(Int64.self, forKey: .resultingCodecId)
        self.fetchedAt = Date()
    }
}

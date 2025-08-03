//
//  DefaultSettings.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation

enum DefaultSettings {
    #if DEBUG
    static let codecConversionId = 1
    #else
    static let codecConversionId = 3 // The MP3 320 codec in our current production ENV
    #endif
}

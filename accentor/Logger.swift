//
//  Logger.swift
//  accentor
//
//  Created by Robbe Van Petegem on 03/08/2025.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let api = Logger(subsystem: subsystem, category: "accentor.api")
    
    static let player = Logger(subsystem: subsystem, category: "accentor.player")
}

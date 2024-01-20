//
//  appDatabase.swift
//  accentor
//
//  Created by Robbe Van Petegem on 15/01/2024.
//

import Foundation
import GRDB
import os.log

/// The Accentor database
///
/// You create an `AppDatabase` with a connection to an SQLite database
/// (see <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>).
///
/// Create those connections with a configuration returned from
/// `AppDatabase/makeConfiguration(_:)`.
///
/// For example:
///
/// ```swift
/// // Create an in-memory AppDatabase
/// let config = AppDatabase.makeConfiguration()
/// let dbQueue = try DatabaseQueue(configuration: config)
/// let appDatabase = try AppDatabase(dbQueue)
/// ```

struct AppDatabase {
    /// Creates an `AppDatabase`, and makes sure the database schema
    /// is ready.
    ///
    /// - important: Create the `DatabaseWriter` with a configuration
    ///   returned by ``makeConfiguration(_:)``.
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
    private let dbWriter: any DatabaseWriter
}


// MARK: - Database Configuration

extension AppDatabase {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

    /// Returns a database configuration.
    ///
    /// SQL statements are logged if the `SQL_TRACE` environment variable
    /// is set.
    ///
    /// - parameter base: A base configuration.
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base

        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        //if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
        if true {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }
        
#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif
        
        return config
    }
}


// MARK: - Database Migrations

extension AppDatabase {
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("20240115 - Create basic models") { db in
            try db.create(table: "album") { table in
                table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("fetchedAt", .datetime).notNull()
                table.column("title", .text).notNull()
                table.column("release", .date)
                table.column("reviewComment", .text)
                table.column("edition", .date)
                table.column("editionDescription", .text)
                table.column("normalizedTitle", .text).notNull()
                table.column("image", .text)
                table.column("image100", .text)
                table.column("image250", .text)
                table.column("image500", .text)
                table.column("imageType", .text)
            }
            
            try db.create(table: "artist") { table in
                table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("fetchedAt", .datetime).notNull()
                table.column("reviewComment", .text)
                table.column("name", .text).notNull()
                table.column("normalizedName", .text).notNull()
                table.column("image", .text)
                table.column("image100", .text)
                table.column("image250", .text)
                table.column("image500", .text)
                table.column("imageType", .text)
            }
            
            try db.create(table: "albumArtist") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("fetchedAt", .datetime).notNull()
                table.column("artistId", .integer).notNull().indexed()
                table.column("name", .text).notNull()
                table.column("normalizedName", .text).notNull()
                table.column("order", .integer).notNull()
                table.column("separator", .text)
                table.belongsTo("album", onDelete: .cascade).notNull()
            }
            
            try db.create(table: "track") { table in
                table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("fetchedAt", .datetime).notNull()
                table.column("reviewComment", .text)
                
                // Internal properties
                table.column("title", .text).notNull()
                table.column("normalizedTitle", .text).notNull()
                table.column("number", .integer)
                
                // Relationships
                table.column("albumId").notNull().indexed()
                
                // Audio file properties
                table.column("codecId", .integer)
                table.column("length", .integer)
                table.column("bitrate", .integer)
                table.column("locationId", .integer)
            }
            
            try db.create(table: "trackArtist") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("artistId", .integer).notNull().indexed()
                table.column("name", .text).notNull()
                table.column("normalizedName", .text).notNull()
                table.column("order", .integer).notNull()
                table.column("role", .text).notNull()
                table.column("hidden", .boolean).notNull()
                table.belongsTo("track", onDelete: .cascade).notNull()
            }
        }
        
        migrator.registerMigration("20240120 - Add plays table") { db in
            try db.create(table: "play") { table in
                table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                table.column("playedAt", .datetime).notNull()
                table.column("trackId", .integer).notNull().indexed()
                table.column("userId", .integer).notNull()
                table.column("fetchedAt", .datetime).notNull()
            }
        }
        
        return migrator
    }
}

// MARK: - Database Access: Writes
// The write methods execute invariant-preserving database transactions.

extension AppDatabase {
    func saveAlbums(albums: [Album], albumArtists: [AlbumArtist]) async throws {
        try await dbWriter.write { db in
            try albums.forEach { album in
                try album.upsert(db)
            }
            try AlbumArtist.filter(albums.map({ $0.id }).contains(Column("albumId"))).deleteAll(db)
            try albumArtists.forEach { aa in
                _ = try aa.saved(db)
            }
        }
    }
    
    func deleteOldAlbums(_ fetchedBefore: Date) async throws {
        try await dbWriter.write { db in
            let count = try Album.filter(Column("fetchedAt") < fetchedBefore).deleteAll(db)
            print("Deleted \(count) old albums")
        }
    }
    
    func saveArtists(_ artists: [Artist]) async throws {
        try await dbWriter.write { db in
            try artists.forEach { artist in
                try artist.upsert(db)
            }
        }
    }
    
    func deleteOldArtists(_ fetchedBefore: Date) async throws {
        try await dbWriter.write { db in
            let count = try Artist.filter(Column("fetchedAt") < fetchedBefore).deleteAll(db)
            print("Deleted \(count) old artists")
        }
    }
    
    func saveTracks(tracks: [Track], trackArtists: [TrackArtist]) async throws {
        try await dbWriter.write { db in
            try tracks.forEach { track in
                try track.upsert(db)
            }
            try TrackArtist.filter(tracks.map({ $0.id }).contains(Column("trackId"))).deleteAll(db)
            try trackArtists.forEach { ta in
                _ = try ta.saved(db)
            }
        }
    }
    
    func deleteOldTracks(_ fetchedBefore: Date) async throws {
        try await dbWriter.write { db in
            let count = try Track.filter(Column("fetchedAt") < fetchedBefore).deleteAll(db)
            print("Deleted \(count) old tracks")
        }
    }
    
    func savePlay(_ play: Play) async throws {
        try await self.savePlays([play])
    }
    
    func savePlays(_ plays: [Play]) async throws {
        try await dbWriter.write { db in
            try plays.forEach { play in
                try play.upsert(db)
            }
        }
    }
    
    func deleteOldPlays(_ fetchedBefore: Date) async throws {
        try await dbWriter.write { db in
            let count = try Play.filter(Column("fetchedAt") < fetchedBefore).deleteAll(db)
            print("Deleted \(count) old plays")
        }
    }
}

// MARK: - Database seeds

extension AppDatabase {
    /// Create random data if the database is empty.
    func createDatabaseSeeds() throws {
        try dbWriter.write { db in
            
        }
    }
}

// MARK: - Database Access: Reads

// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension AppDatabase {
    /// Provides a read-only access to the database
    var reader: DatabaseReader {
        dbWriter
    }
}

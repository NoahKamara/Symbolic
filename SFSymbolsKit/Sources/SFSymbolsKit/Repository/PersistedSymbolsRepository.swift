//
//  PersistedSymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB

public struct PersistedSymbolsRepository: SFSymbolsRepository {
    private let database: DatabaseWriter

    public init(database: DatabaseWriter) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("create_symbols_table") { db in
            try db.create(table: SFSymbol.databaseTableName) { t in
                t.column("name", .text).unique()
                t.column("availability", .text).notNull()
                t.column("hierarchicalAvailability", .text)
                t.column("multicolorAvailability", .text)
                t.column("categories")
                t.column("aliases")
            }
        }

        migrator.registerMigration("create_categories_table") { db in
            try db.create(table: SFSymbolCategory.databaseTableName) { t in
                t.column("key", .text).unique()
                t.column("label", .text)
                t.column("icon", .text)
                t.column("name", .text).unique()
            }
        }

        migrator.registerMigration("create_releases_table") { db in
            try db.create(table: SFSymbolsRelease.databaseTableName) { t in
                t.column("year", .text).unique()
                t.column("iOS", .text)
                t.column("macOS", .text)
                t.column("visionOS", .text)
                t.column("watchOS", .text)
            }
        }

        try migrator.migrate(database)

        self.database = database
    }

    public init(at path: String) throws {
        let database = try DatabaseQueue(path: path)
        try self.init(database: database)
    }

    public func symbol(named name: SFSymbol.ID) async throws -> SFSymbol? {
        try await database.read { db in
            try SFSymbol.filter(Column("name") == name).fetchOne(db)
        }
    }

    public func release(for year: SFSymbolsRelease.ID) async throws -> SFSymbolsRelease? {
        try await database.read { db in
            try SFSymbolsRelease.filter(Column("year") == year).fetchOne(db)
        }
    }

    public func category(forKey key: SFSymbolCategory.ID) async throws -> SFSymbolCategory? {
        try await database.read { db in
            try SFSymbolCategory.filter(Column("key") == key).fetchOne(db)
        }
    }
}

extension PersistedSymbolsRepository: SFSymbolsRepositoryWriter {
    package func insertSymbol(_ symbol: SFSymbol) async throws {
        try await database.write { db in
            try symbol.insert(db)
        }
    }

    package func insertRelease(_ release: SFSymbolsRelease) async throws {
        try await database.write { db in
            try release.insert(db)
        }
    }

    package func insertCategory(_ category: SFSymbolCategory) async throws {
        try await database.write { db in
            try category.insert(db)
        }
    }
}

extension SFSymbol: FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "symbols"
}

extension SFSymbolCategory: FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "categories"
}

extension SFSymbolsRelease: FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "release"
}

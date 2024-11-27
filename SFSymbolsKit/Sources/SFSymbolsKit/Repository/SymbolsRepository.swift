//
//  SymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB

public extension SymbolsFetchRequest {
    func makeQueryInterfaceRequest() -> QueryInterfaceRequest<SFSymbol> {
        var request = SFSymbol.all()

        if let category {
            request = request.filter(Column("category") == category)
        }

        return request
    }
}

enum Related {
    struct SymbolCategory {}
}

public struct SymbolsRepository: SFSymbolsRepository {
    private let database: DatabaseWriter

    public init(database: DatabaseWriter) throws {
        try Self.migrator.migrate(database)
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

    public func symbols(for request: SymbolsFetchRequest) async throws -> [SFSymbol] {
        var query = SFSymbol.all()

        if let categoryKey = request.category {
            let categoryId = try await database.read { db in
                try SFSymbolsCategory
                    .filter(Column("key") == categoryKey)
                    .select(Column("id"))
                    .asRequest(of: Int64.self)
                    .fetchOne(db)
            }

            guard let categoryId else { return [] }

            query = query
                .joining(required: SFSymbol.symbolCategories.filter(Column("categoryId") == categoryId))
        }

        let dbQuery = query

        return try await database.read { db in
            try dbQuery.fetchAll(db)
        }
    }

    public func symbols() async throws -> [SFSymbol] {
        try await database.read { db in
            try SFSymbol.fetchAll(db)
        }
    }

    public func release(for year: SFSymbolsRelease.ID) async throws -> SFSymbolsRelease? {
        try await database.read { db in
            try SFSymbolsRelease.filter(Column("year") == year).fetchOne(db)
        }
    }

    public func category(forKey key: SFSymbolsCategory.ID) async throws -> SFSymbolsCategory? {
        try await database.read { db in
            try SFSymbolsCategory.filter(Column("key") == key).fetchOne(db)
        }
    }

    public func categories() async throws -> [SFSymbolsCategory] {
        try await database.read { db in
            try SFSymbolsCategory.fetchAll(db)
        }
    }
}

public extension SymbolsRepository {
    static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("create_symbols_table") { db in
            try db.create(table: SFSymbol.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("availability", .text).notNull()
//                t.column("hierarchicalAvailability", .text)
//                t.column("multicolorAvailability", .text)
//                t.column("categories")
//                t.column("aliases")
            }
        }

        migrator.registerMigration("create_aliases_table") { db in
            // Create the aliases table
            try db.create(table: Persistence.SymbolAlias.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("symbolId", .integer).notNull().references("symbols", onDelete: .cascade)
                t.column("alias", .text).notNull()
            }
        }

        migrator.registerMigration("create_categories_table") { db in
            try db.create(table: SFSymbolsCategory.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("key", .text).unique()
                t.column("label", .text)
                t.column("icon", .text)
            }
        }

        migrator.registerMigration("create_symbol_categories_table") { db in
            // Create the aliases table
            try db.create(table: "symbol_categories") { t in
                t.autoIncrementedPrimaryKey("id")
                t
                    .column("symbolId", .integer)
                    .notNull()
                    .references(SFSymbol.databaseTableName, onDelete: .cascade)
                t
                    .column("categoryId", .integer)
                    .notNull()
                    .references(SFSymbolsCategory.databaseTableName, onDelete: .cascade)
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

        migrator.registerMigration("create_search_table") { db in
            try db.create(virtualTable: "symbolsFTS", using: FTS5()) { t in
                t.column("name")
                t.column("aliases")
                t.column("categories")
            }
        }

        return migrator
    }()
}

struct IndexedRecord: Codable, PersistableRecord {
    static let databaseTableName: String = "symbolsFTS"

    let name: String
    let aliases: [String]
    let categories: [String]
}

private struct SymbolCategory: Codable, PersistableRecord {
    static let databaseTableName: String = "symbol_categories"

    let symbolId: UInt64
    let categoryId: UInt64

    static let symbol = belongsTo(SFSymbol.self)
    static let category = belongsTo(SymbolCategory.self)
}

extension SFSymbolsCategory: FetchableRecord, PersistableRecord {
    public static let databaseTableName = "categories"
    fileprivate static let symbols = hasMany(SymbolCategory.self)
}

extension SFSymbol: FetchableRecord, PersistableRecord {
    public static let databaseTableName = "symbols"
    fileprivate static let symbolCategories = hasMany(SymbolCategory.self)
}

extension SFSymbolsRelease: FetchableRecord, PersistableRecord {
    public static let databaseTableName = "releases"
}

enum Persistence {
//    struct Symbol: Codable, PersistableRecord, FetchableRecord {
//        static let category = belongsTo(SymbolCategory.self)
//        static let databaseTableName: String = "symbols"
//
//        var id: Int64?
//        let name: String
//        let availability: String
//
//        mutating func didInsert(_ inserted: InsertionSuccess) {
//            self.id = inserted.rowID
//        }
//    }

    struct SymbolAlias: Codable, PersistableRecord, FetchableRecord {
        static let databaseTableName: String = "symbol_aliases"

        let alias: String
        let symbolId: Int64
        let legacy: Bool
    }
}

extension SymbolsRepository: SFSymbolsRepositoryWriter {
    package func insertSymbols(_ symbols: [SFSymbol]) async throws {
        try await database.write { db in
            for symbol in symbols {
                try symbol.inserted(db)
            }
//            let record = IndexedRecord(
//                name: symbol.name,
//                aliases: symbol.aliases,
//                categories: symbol.categories
//            )
//            try record.insert(db)
        }
    }

    package func insertSymbolCategories(_ symbolCategories: [String: [String]]) async throws {
        try await database.write { db in
            for (symbolName, category_keys) in symbolCategories {
                let symbolId = try SFSymbol
                    .filter(Column("name") == symbolName)
                    .select(Column("id"))
                    .asRequest(of: Int64.self)
                    .fetchOne(db)

                for category_key in category_keys {
                    try db.execute(literal: """
                    INSERT INTO symbol_categories (symbolId, categoryId)
                    VALUES (\(symbolId), (SELECT id FROM categories WHERE key = \(category_key)))
                    """)
                }
            }
        }
    }

    package func insertSymbolAliases(legacy: Bool = false, _ nameAliases: [String: [String]]) async throws {
        try await database.write { db in
            for (symbolName, aliases) in nameAliases {
                for alias in aliases {
                    try db.execute(literal: """
                    INSERT INTO symbol_aliases (alias, symbolId)
                    VALUES (\(alias), (SELECT id FROM symbols WHERE name = \(symbolName)))
                    """)
                }
            }
        }
    }

    package func insertReleases(_ releases: [SFSymbolsRelease]) async throws {
        try await database.write { db in
            for release in releases {
                try release.insert(db)
            }
        }
    }

    package func insertCategories(_ categories: [SFSymbolsCategory]) async throws {
        try await database.write { db in
            for category in categories {
                try category.insert(db)
            }
        }
    }
}

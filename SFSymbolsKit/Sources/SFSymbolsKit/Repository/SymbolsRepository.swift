//
//  SymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB

public struct SymbolsFetchRequest: Sendable {
    public let searchTerm: String?
    public let category: SFCategory.Key?

    public init(searchTerm: String? = nil, category: SFCategory.Key? = nil) {
        self.searchTerm = searchTerm
        self.category = category
    }

    public static let all = SymbolsFetchRequest()

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

public struct SymbolsRepository {
    package let database: DatabaseWriter

    public init(database: DatabaseWriter) throws {
        try Self.migrator.migrate(database)
        self.database = database
    }

    public init(at path: String) throws {
        let database = try DatabaseQueue(path: path)
        try self.init(database: database)
    }

    public func symbol(named name: SFSymbol.Name) async throws -> SFSymbol? {
        try await database.read { db in
            try SFSymbol.filter(Column("name") == name).fetchOne(db)
        }
    }

    public func symbols(for request: SymbolsFetchRequest) async throws -> [SFSymbol] {
        var query = SFSymbol.all()

        if let categoryKey = request.category {
            let categoryId = try await database.read { db in
                try SFCategory
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

    public func release(for year: SFRelease.Year) async throws -> SFRelease? {
        try await database.read { db in
            try SFRelease.filter(Column("year") == year).fetchOne(db)
        }
    }

    public func category(forKey key: SFCategory.Key) async throws -> SFCategory? {
        try await database.read { db in
            try SFCategory.filter(Column("key") == key).fetchOne(db)
        }
    }

    public func categories() async throws -> [SFCategory] {
        try await database.read { db in
            try SFCategory.fetchAll(db)
        }
    }

    public func clear() async throws {
        try await database.write { db in
            try db.execute(sql: "DELETE FROM symbol_categories")
            try db.execute(sql: "DELETE FROM symbol_aliases")
            try db.execute(sql: "DELETE FROM symbols")
            try db.execute(sql: "DELETE FROM categories")
            try db.execute(sql: "DELETE FROM releases")
        }
    }
}

public extension SymbolsRepository {
    static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("init") { db in
            try db.create(table: SFRelease.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("year", .text).unique()
                t.column("iOS", .text)
                t.column("macOS", .text)
                t.column("visionOS", .text)
                t.column("watchOS", .text)
            }
            
            try db.create(table: SFSymbol.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("introducedId", .integer)
            }
            
            try db.create(table: SFCategory.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("key", .text).unique()
                t.column("label", .text)
                t.column("icon", .text)
            }
            
            try db.create(table: SFLayerset.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).unique()
            }
            
            // MARK: Aliases
            try db.create(table: SFSymbolCategory.databaseTableName) { t in
                t
                    .column("symbolId", .integer)
                    .notNull()
                    .references(SFSymbol.databaseTableName, onDelete: .cascade)
                t
                    .column("categoryId", .integer)
                    .notNull()
                    .references(SFCategory.databaseTableName, onDelete: .cascade)
            }
            
            try db.create(table: SFLayersetAvailability.databaseTableName) { t in
                t
                    .column("symbolId", .integer)
                    .notNull()
                    .references(SFSymbol.databaseTableName, onDelete: .cascade)
                t
                    .column("layersetId", .integer)
                    .notNull()
                    .references(SFLayerset.databaseTableName, onDelete: .cascade)
                t
                    .column("introducedId", .integer)
                    .notNull()
                    .references(SFRelease.databaseTableName, onDelete: .cascade)
            }
            
            // MARK: Search
            try db.create(virtualTable: SFSymbolSearchRecord.databaseTableName, using: FTS5()) { t in
                t.column("id").notIndexed()
                t.column("name")
                t.column("aliases")
                t.column("keywords")
            }
        }

//        migrator.registerMigration("create_aliases_table") { db in
//            // Create the aliases table
//            try db.create(table: Persistence.SymbolAlias.databaseTableName) { t in
//                t.autoIncrementedPrimaryKey("id")
//                t.column("symbolId", .integer).notNull().references("symbols", onDelete: .cascade)
//                t.column("alias", .text).notNull()
//            }
//        }
        
        

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

extension SFSymbol: FetchableRecord, PersistableRecord {
    public static let databaseTableName = "symbols"
    fileprivate static let symbolCategories = hasMany(SymbolCategory.self)
}

extension SFRelease: FetchableRecord, PersistableRecord {
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


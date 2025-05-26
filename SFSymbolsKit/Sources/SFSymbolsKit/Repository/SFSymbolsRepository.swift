//
//  SFSymbolsRepository.swift
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

public struct SFSymbolsRepository {
    package let database: DatabaseWriter

    struct UnpreparedDatabaseError: Error, LocalizedError {
        var errorDescription: String {
            "Database is not prepared. Run `SFSymbolsRepository.prepare()`"
        }
    }
    
    /// Creates a SFSymbolsRepository from a database
    public init(database: DatabaseWriter, createIfMissing: Bool) throws {
        self.database = database
        try prepare()
        
        let isInitialized = try database.read { db in
            try db.tableExists("meta")
        }

        if !isInitialized {
            if createIfMissing {
                print("Initializing Database")
                try prepare()
            } else {
                throw UnpreparedDatabaseError()
            }
        }
    }

    /// Creates an in-memory SFSymbolsRepository
    static func inMemory() throws -> Self {
        try SFSymbolsRepository(database: DatabaseQueue(), createIfMissing: true)
    }

    public init(at path: String, createIfMissing: Bool) throws {
        let database = try DatabaseQueue(path: path)
        try self.init(database: database, createIfMissing: createIfMissing)
    }

    package func prepare() throws {
        try Self.migrator.migrate(database)
    }

    public func symbol(named name: SFSymbol.Name) async throws -> SFSymbol? {
        try await database.read { db in
            try SFSymbol.filter(Column("name") == name).fetchOne(db)
        }
    }
    
    
    public func detail(for name: SFSymbol.Name) async throws -> SFSymbolDetail? {
        try await database.read { db in
            let request = SFSymbol
                .filter(Column("name") == name)
                .including(required: SFSymbol.release)
                .including(all: SFSymbol.categories)
                .including(all: SFSymbol.layersetAvailability
                    .including(required: SFLayersetAvailability.layerset)
                    .including(required: SFLayersetAvailability.release))
            
            return try request.asRequest(of: SFSymbolDetail.self).fetchOne(db)
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
                .joining(required: SFSymbol.categories.filter(Column("categoryId") == categoryId))
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

    public func layersets() async throws -> [SFLayerset] {
        try await database.read { db in
            try SFLayerset.fetchAll(db)
        }
    }

    public func releases() async throws -> [SFRelease] {
        try await database.read { db in
            try SFRelease
                .order(Column("year"))
                .fetchAll(db)
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



public extension SFSymbolsRepository {
    static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("init") { db in
            try db.create(table: "meta") { t in
                t.primaryKey("id", .integer, onConflict: .replace).defaults(to: 1).check { $0 == 1 }
                t.column("version")
            }
            
            try db.execute(literal: "INSERT INTO meta (version) VALUES ('0.1.0')")
            
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
                t.column("releaseId", .integer).references(SFRelease.databaseTableName)
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
                    .column("releaseId", .integer)
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


//
//  File.swift
//  SFSymbolsKit
//
//  Created by Noah Kamara on 25.05.2025.
//

import SFSymbolsKit

extension SFSymbolsRepository {
    func insertReleases(_ releases: [SFRelease]) async throws -> [SFRelease.Year: SFRelease.RowID] {
        try await database.write { db in
            var ids = [String: Int64]()
            for release in releases {
                let reference = try release.insertAndFetch(db, as: Reference.self)
                ids[release.year] = reference.id
            }
            return ids
        }
    }

    func insertCategories(_ categories: [SFCategory]) async throws -> [SFCategory.Key: SFCategory.RowID] {
        try await database.write { db in
            var ids = [String: Int64]()
            for category in categories {
                let reference = try category.insertAndFetch(db, as: Reference.self)
                ids[category.key] = reference.id
            }
            return ids
        }
    }

    func insertLayersets(
        _ symbolCategories: [SFLayerset]
    ) async throws -> [SFLayerset.Name: SFLayerset.RowID] {
        try await database.write { db in
            var ids = [String: Int64]()
            for symbolCategory in symbolCategories {
                try symbolCategory.insert(db)
                ids[symbolCategory.name] = db.lastInsertedRowID
            }
            return ids
        }
    }

    func insertSymbols(_ symbols: [SFSymbol]) async throws -> [SFSymbol.Name: SFSymbol.RowID] {
        try await database.write { db in
            var ids = [String: Int64]()
            for symbol in symbols {
                let reference = try symbol.insertAndFetch(db, as: Reference.self)
                ids[symbol.name] = reference.id
            }
            return ids
        }
    }

    func insertSymbolCategories(
        _ symbolCategories: [SFSymbolCategory]
    ) async throws {
        try await database.write { db in
            for symbolCategory in symbolCategories {
                try symbolCategory.insert(db)
            }
        }
    }

    func insertLayersetAvailabilities(
        _ layersetAvailabilities: [SFLayersetAvailability]
    ) async throws {
        try await database.write { db in
            for layersetAvailability in layersetAvailabilities {
                try layersetAvailability.insert(db)
            }
        }
    }
    
    func insertSearchRecords(
        _ searchRecords: [SFSymbolSearchRecord]
    ) async throws {
        try await database.write { db in
            for searchRecord in searchRecords {
                try searchRecord.insert(db)
            }
        }
    }
    
    func insertSymbolAliases(legacy: Bool = false, _ nameAliases: [String: [String]]) async throws {
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
}


struct Reference: SFModel {
    let id: RowID
}

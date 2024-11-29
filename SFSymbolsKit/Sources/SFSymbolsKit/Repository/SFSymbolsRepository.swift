//
//  SFSymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

/// The interface for a repository providing SFSymbols metadata
public protocol SFSymbolsRepository: Sendable {
    func symbol(named name: SFSymbol.ID) async throws -> SFSymbol?
    func symbols(for request: SymbolsFetchRequest) async throws -> [SFSymbol]

    func release(for year: SFSymbolsRelease.ID) async throws -> SFSymbolsRelease?

    func category(forKey key: SFSymbolsCategory.ID) async throws -> SFSymbolsCategory?
    func categories() async throws -> [SFSymbolsCategory]
}

public extension SFSymbolsRepository {
    func symbols() async throws -> [SFSymbol] { try await symbols(for: .all) }
}

public struct SymbolsFetchRequest: Sendable {
    public let searchTerm: String?
    public let category: SFSymbolsCategory.ID?

    public init(searchTerm: String? = nil, category: SFSymbolsCategory.ID? = nil) {
        self.searchTerm = searchTerm
        self.category = category
    }

    public static let all = SymbolsFetchRequest()
}

extension SFSymbolsRepository {
    func symbols(for request: SymbolsFetchRequest) async throws -> [SFSymbol] {
        try await symbols()
    }
}

/// a writer for a `SFSymbolsRepository`
package protocol SFSymbolsRepositoryWriter: SFSymbolsRepository {
    func insertSymbols(_ symbols: [SFSymbol]) async throws
    func insertReleases(_ releases: [SFSymbolsRelease]) async throws
    func insertCategories(_ categories: [SFSymbolsCategory]) async throws
}

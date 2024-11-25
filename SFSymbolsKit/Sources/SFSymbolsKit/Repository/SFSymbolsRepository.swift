//
//  SFSymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

/// The interface for a repository providing SFSymbols metadata
public protocol SFSymbolsRepository {
    func symbol(named name: SFSymbol.ID) async throws -> SFSymbol?
    func release(for year: SFSymbolsRelease.ID) async throws -> SFSymbolsRelease?
    func category(forKey key: SFSymbolCategory.ID) async throws -> SFSymbolCategory?
}

/// a writer for a `SFSymbolsRepository`
package protocol SFSymbolsRepositoryWriter: SFSymbolsRepository {
    func insertSymbol(_ symbol: SFSymbol) async throws
    func insertRelease(_ release: SFSymbolsRelease) async throws
    func insertCategory(_ category: SFSymbolCategory) async throws
}

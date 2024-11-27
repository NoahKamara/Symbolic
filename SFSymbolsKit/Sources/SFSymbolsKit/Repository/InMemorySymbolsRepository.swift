//
//  InMemorySymbolsRepository.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

// public actor InMemorySymbolsRepository: SFSymbolsRepository, SFSymbolsRepositoryWriter {
//    private var symbols: [String: SFSymbol] = [:]
//    private var releases: [String: SFSymbolsRelease] = [:]
//    private var categories: [String: SFSymbolCategory] = [:]
//
//    public init() {}
//
//    public func symbol(named name: String) async -> SFSymbol? {
//        symbols[name]
//    }
//
//    public func release(for year: String) async -> SFSymbolsRelease? {
//        releases[year]
//    }
//
//    public func category(forKey key: SFSymbolCategory.ID) async throws -> SFSymbolCategory? {
//        categories[key]
//    }
//    public func categories() async throws -> [SFSymbolCategory] {
//        <#code#>
//    }
// }
//
// package extension InMemorySymbolsRepository {
//    func insertSymbol(_ symbol: SFSymbol) {
//        precondition(symbols[symbol.name] == nil, "duplicate symbol \(symbol.name)")
//        symbols[symbol.name] = symbol
//    }
//
//    func insertCategory(_ category: SFSymbolCategory) async {
//        categories[category.key] = category
//    }
//
//    func insertRelease(_ release: SFSymbolsRelease) async {
//        releases[release.year] = release
//    }
// }

// SFSymbolsRepositoryWriter

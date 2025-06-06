//
//  SFSymbolsApp.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SFSymbolsKit

struct SFSymbolsApp {
    let appUrl: URL

    init(appUrl: URL) {
        self.appUrl = appUrl
    }

    var metadataDirectory: URL {
        appUrl.appending(components: "Contents", "Resources", "Metadata")
    }

    private func load(_ file: String) throws -> Data {
        try Data(contentsOf: metadataDirectory.appending(component: file))
    }

    private func loadPlist<T: Decodable>(_ file: String, as type: T.Type = T.self) throws -> T {
        let data: Data = try load(file)
        let value = try PropertyListDecoder().decode(T.self, from: data)
        return value
    }

    fileprivate nonisolated(unsafe) static let stringsLineRegex = /"([\w\.]+)" = "([\w\.]+)";/

    private func loadStrings(_ file: String) throws -> [String: String] {
        let data: Data = try load(file)
        guard let string = String(data: data, encoding: .utf8) else {
            return [:]
        }

        let lines = string.components(separatedBy: .newlines)
        var result: [String: String] = [:]

        for (i, line) in lines.enumerated() {
            let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else {
                continue
            }
            guard let match = try Self.stringsLineRegex.wholeMatch(in: line) else {
                fatalError("failed to read at line \(i)")
            }

            let (_, key, value) = match.output
            if result.keys.contains(String(key)) {
                print("OH NO")
            }

            result[String(key)] = String(value)
        }

        return result
    }

    private func layersetAvailabilityPlist() throws -> AvailabilityPlist<[String: String]> {
        try loadPlist("layerset_availability.plist")
    }

    private func nameAvailabilityPlist() throws -> AvailabilityPlist<String> {
        try loadPlist("name_availability.plist")
    }

    private func categoriesPlist() throws -> [SFCategory] {
        try loadPlist("categories.plist")
    }

    private func symbolCategoriesPlist() throws -> [String: [String]] {
        try loadPlist("symbol_categories.plist")
    }

    private func symbolSearchPlist() throws -> [String: [String]] {
        try loadPlist("symbol_search.plist")
    }

    private func nameAliasesStrings() throws -> [String: String] {
        try loadStrings("name_aliases.strings")
    }

    private func legacyAliasesStrings() throws -> [String: String] {
        try loadStrings("legacy_aliases.strings")
    }
}

// MARK: Extractor

extension SFSymbolsApp {
    func extract(into repository: SFSymbolsRepository) async throws {
        print("Extracting Symbols from \(metadataDirectory.path(percentEncoded: false))")
        // Load files
        let categories = try categoriesPlist()
        let nameAvailability = try nameAvailabilityPlist()
        let layersetAvailability = try layersetAvailabilityPlist()
        let nameAliases = try nameAliasesStrings()
        let symbolSearch = try symbolSearchPlist()

        // Categories
        let categoryIds = try await repository.insertCategories(categories)

        // Releases
        // we need to merge name and layerset availability
        let releases = nameAvailability.yearToRelease
            .merging(layersetAvailability.yearToRelease, uniquingKeysWith: { first, _ in first })
            .map { SFRelease(year: $0.key, platforms: $0.value) }

        let releaseIds = try await repository.insertReleases(releases)

        // Insert Layersets
        let layersets = layersetAvailability.symbols.values
            .reduce(Set<String>()) { layersets, map in
                layersets.union(map.keys)
            }
            .map {
                SFLayerset(name: $0)
            }

        let layersetIds = try await repository.insertLayersets(layersets)

        // Symbols
        let symbols: [SFSymbol] = nameAvailability
            .symbols
            .map { name, releaseYear in
                SFSymbol(
                    name: name,
                    releaseId: releaseIds[releaseYear]!
                )
            }

        let symbolIds = try await repository.insertSymbols(symbols)

        // Symbol Categories
        let symbolCategoriesPlist = try symbolCategoriesPlist()

        let symbolCategories = symbolCategoriesPlist.flatMap { symbolName, categoryKeys in
            let symbolId = symbolIds[symbolName]!

            return categoryKeys.map { categoryKey in
                let categoryId = categoryIds[categoryKey]!
                return SFSymbolCategory(symbolId: symbolId, categoryId: categoryId)
            }
        }
        try await repository.insertSymbolCategories(symbolCategories)

        // Insert Symbol Layerset Availability
        let layersetAvailabilities = layersetAvailability.symbols.flatMap { symbol, layersets in
            let symbolId = symbolIds[symbol]!

            return layersets.map { layerset, year in
                SFLayersetAvailability(
                    symbolId: symbolId,
                    layersetId: layersetIds[layerset]!,
                    releaseId: releaseIds[year]!
                )
            }
        }

        try await repository.insertLayersetAvailabilities(layersetAvailabilities)

        // Search
        let aliasesForName = nameAliases.valuesAsKeys()
        let searchRecords = symbolIds.map { symbolName, symbolId in
            SFSymbolSearchRecord(
                id: symbolId,
                name: symbolName,
                aliases: aliasesForName[symbolName] ?? [],
                keywords: symbolSearch[symbolName] ?? []
            )
        }

        try await repository.insertSearchRecords(searchRecords)

        //        // Aliases
        //        let nameAliases = try nameAliasesStrings().valuesAsKeys()
        //        try await repository.insertSymbolAliases(nameAliases)
        //
        //        // Legacy Aliases
        //        //        let legacyAliases = try legacyAliasesStrings().valuesAsKeys()
        //        #warning("legacyAliases not yet implemented")

        print("Releases: \(releaseIds.count)")
        print("Categories: \(categoryIds.count)")
        print("Symbols: \(symbolIds.count)")
        print("Search Records \(searchRecords.count)")
        print("Layersets: \(layersets.count)")
    }
}

private extension Dictionary where Value: Hashable {
    func valuesAsKeys() -> [Value: [Key]] {
        reduce(into: [Value: [Key]]()) { result, element in
            var existing = result[element.value] ?? []

            if !existing.contains(element.key) {
                existing.append(element.key)
            }

            result[element.value] = existing
        }
    }
}

private struct AvailabilityPlist<Item: Decodable>: Decodable {
    public typealias Year = String

    let symbols: [String: Item]
    let yearToRelease: [Year: PlatformVersions]

    init(symbols: [String: Item], yearToRelease: [Year: PlatformVersions]) {
        self.symbols = symbols
        self.yearToRelease = yearToRelease
    }

    enum CodingKeys: String, CodingKey {
        case symbols
        case yearToRelease = "year_to_release"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.symbols = try container.decode([String: Item].self, forKey: .symbols)
        self.yearToRelease = try container.decode(
            [Year: PlatformVersions].self,
            forKey: .yearToRelease
        )
    }
}

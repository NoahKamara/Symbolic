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
        print("loading '\(file)'")
        return try Data(contentsOf: metadataDirectory.appending(component: file))
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

    private func categoriesPlist() throws -> [SFSymbolsCategory] {
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
    func extract(into repository: SymbolsRepository) async throws {
        // Categories
        let categories = try categoriesPlist()
        try await repository.insertCategories(categories)

        // insert releases
        let nameAvailability = try nameAvailabilityPlist()
        let layersetAvailability = try layersetAvailabilityPlist()

        let releases = nameAvailability.yearToRelease
            .merging(layersetAvailability.yearToRelease, uniquingKeysWith: { name, _ in name })
            .map { SFSymbolsRelease(year: $0.key, platforms: $0.value) }

        try await repository.insertReleases(releases)

        // Insert Symbols
        let symbols = nameAvailability
            .symbols
            .map { SFSymbol(name: $0.key, availability: $0.value) }
        try await repository.insertSymbols(symbols)

        // Insert Layerset Availability
        #warning("insert layerset availability")

        // Symbol Categories
        let symbolCategories = try symbolCategoriesPlist()
        try await repository.insertSymbolCategories(symbolCategories)

        // Aliases
        let nameAliases = try nameAliasesStrings().valuesAsKeys()
        try await repository.insertSymbolAliases(nameAliases)

        // Legacy Aliases
        let legacyAliases = try legacyAliasesStrings().valuesAsKeys()
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
        self.yearToRelease = try container.decode([Year: PlatformVersions].self, forKey: .yearToRelease)
    }
}

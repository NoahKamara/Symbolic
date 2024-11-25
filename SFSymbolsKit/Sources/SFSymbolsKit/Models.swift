//
//  Models.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct SFSymbolCategory: Codable, Sendable {
    public typealias ID = String

    public let key: ID
    public let label: String
    public let icon: String

    public init(key: ID, label: String, icon: String) {
        self.key = key
        self.label = label
        self.icon = icon
    }
}

public struct SFSymbol: Codable, Sendable {
    public typealias ID = String

    public let name: ID
    public let availability: String
    public let hierarchicalAvailability: String?
    public let multicolorAvailability: String?
    public let categories: [SFSymbolCategory.ID]
    public let aliases: [String]

    public init(
        name: ID,
        availability: String,
        hierarchicalAvailability: String?,
        multicolorAvailability: String?,
        categories: [SFSymbolCategory.ID],
        aliases: [String]
    ) {
        self.name = name
        self.availability = availability
        self.hierarchicalAvailability = hierarchicalAvailability
        self.multicolorAvailability = multicolorAvailability
        self.categories = categories
        self.aliases = aliases
    }
}

public struct SFSymbolsRelease: Codable, Sendable {
    public typealias ID = String

    public let year: ID
    public let platforms: PlatformVersions

    public init(year: String, platforms: PlatformVersions) {
        self.year = year
        self.platforms = platforms
    }

    enum CodingKeys: CodingKey {
        case year
        case iOS
        case macOS
        case visionOS
        case watchOS
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(year, forKey: .year)
        try container.encode(platforms.iOS, forKey: .iOS)
        try container.encode(platforms.macOS, forKey: .macOS)
        try container.encode(platforms.visionOS, forKey: .visionOS)
        try container.encode(platforms.watchOS, forKey: .watchOS)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.year = try container.decode(SFSymbolsRelease.ID.self, forKey: .year)

        let iOS = try container.decode(SemantivVersion.self, forKey: .iOS)
        let macOS = try container.decode(SemantivVersion.self, forKey: .macOS)
        let visionOS = try container.decode(SemantivVersion.self, forKey: .visionOS)
        let watchOS = try container.decode(SemantivVersion.self, forKey: .watchOS)

        self.platforms = PlatformVersions(
            iOS: iOS,
            macOS: macOS,
            visionOS: visionOS,
            watchOS: watchOS
        )
    }
}

public typealias SemantivVersion = String

public struct PlatformVersions: Codable, Sendable {
    public let iOS: SemantivVersion
    public let macOS: SemantivVersion
    public let visionOS: SemantivVersion
    public let watchOS: SemantivVersion
}

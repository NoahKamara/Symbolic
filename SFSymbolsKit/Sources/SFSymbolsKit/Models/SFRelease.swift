//
//  SFRelease.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

public struct SFRelease: SFModel {
    public static let databaseTableName = "releases"
    
    public typealias Year = String

    public let year: Year
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
        self.year = try container.decode(SFRelease.Year.self, forKey: .year)

        let iOS = try container.decode(SemanticVersion.self, forKey: .iOS)
        let macOS = try container.decode(SemanticVersion.self, forKey: .macOS)
        let visionOS = try container.decode(SemanticVersion.self, forKey: .visionOS)
        let watchOS = try container.decode(SemanticVersion.self, forKey: .watchOS)

        self.platforms = PlatformVersions(
            iOS: iOS,
            macOS: macOS,
            visionOS: visionOS,
            watchOS: watchOS
        )
    }
}

extension SFRelease: Equatable, Comparable {
    public static func == (lhs: SFRelease, rhs: SFRelease) -> Bool {
        return lhs.year == rhs.year
    }
    
    public static func < (lhs: SFRelease, rhs: SFRelease) -> Bool {
        return lhs.year < rhs.year
    }
    

}

public typealias SemanticVersion = String

public struct PlatformVersions: Codable, Sendable {
    public let iOS: SemanticVersion
    public let macOS: SemanticVersion
    public let visionOS: SemanticVersion
    public let watchOS: SemanticVersion

    public init(
        iOS: SemanticVersion,
        macOS: SemanticVersion,
        visionOS: SemanticVersion,
        watchOS: SemanticVersion
    ) {
        self.iOS = iOS
        self.macOS = macOS
        self.visionOS = visionOS
        self.watchOS = watchOS
    }
}

//
//  SFSymbol.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import GRDB

public struct SFSymbol: SFModel {
    public static let databaseTableName = "symbols"

    public static let release = belongsTo(SFRelease.self)
    
    private static let categoryIds = hasMany(SFSymbolCategory.self)
    public static let categories = hasMany(
        SFCategory.self,
        through: categoryIds,
        using: SFSymbolCategory.category
    )

    static let layersetAvailability = hasMany(SFLayersetAvailability.self)
    
    public typealias Name = String

    public let name: Name
    public let releaseId: SFRelease.RowID

    public init(
        name: Name,
        releaseId: SFRelease.RowID
    ) {
        self.name = name
        self.releaseId = releaseId
    }
}

public struct SFSymbolDetail: SFRelation {
    public let id: Int64
    public let name: SFSymbol.Name
    public let release: SFRelease
    public let categories: [SFCategory]
    public let layersetAvailability: [SFLayersetAvailabilityDetail]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case release
        case categories
        case layersetAvailability = "layer_availabilities"
    }
}

public struct SFLayersetAvailabilityDetail: SFRelation {
    public let layerset: SFLayerset
    public let release: SFRelease
}


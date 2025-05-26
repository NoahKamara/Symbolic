//
//  SFSymbol.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import GRDB

public struct SFSymbol: SFModel {
    public static let databaseTableName = "symbols"

    private static let categoryIds = hasMany(SFSymbolCategory.self)
    public static let categories = hasMany(
        SFCategory.self,
        through: categoryIds,
        using: SFSymbolCategory.category
    )

    private static let layersetAvailabilityIds = hasMany(SFLayersetAvailability.self)
    
    public static let layersetAvailability = hasMany(
        SFLayerset.self,
        through: layersetAvailabilityIds,
        using: SFLayersetAvailability.layerset
    )
    
    public typealias Name = String

    public let name: Name
    public let introducedId: SFRelease.RowID

    public init(
        name: Name,
        introducedId: SFRelease.RowID
    ) {
        self.name = name
        self.introducedId = introducedId
    }
}

public struct SFSymbolDetail: SFRelation {
    public let id: Int64
    public let name: SFSymbol.Name
    public let categories: [SFCategory]
    public let layersetAvailability: [SFLayersetAvailabilityDetail]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case categories
        case layersetAvailability = "layer_availabilities"
    }
}

public struct SFLayersetAvailabilityDetail: SFRelation {
    public let layerset: SFLayerset
    public let release: SFRelease
}

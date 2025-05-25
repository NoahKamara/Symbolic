//
//  SFLayerset.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

public struct SFLayerset: SFModel {
    public static let databaseTableName = "layersets"

    public typealias Name = String
    public let name: Name

    package init(name: Name) {
        self.name = name
    }
}

public struct SFLayersetAvailability: SFRelation {
    public static let databaseTableName = "layer_availability"
    public let symbolId: SFSymbol.RowID
    public let layersetId: SFLayerset.RowID
    public let introducedId: SFRelease.RowID

    package init(
        symbolId: SFSymbol.RowID,
        layersetId: SFLayerset.RowID,
        introducedId: SFRelease.RowID
    ) {
        self.symbolId = symbolId
        self.layersetId = layersetId
        self.introducedId = introducedId
    }
}

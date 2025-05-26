//
//  SFLayerset.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import GRDB

public struct SFLayerset: SFModel, Hashable {
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
    public let releaseId: SFRelease.RowID

    public static let layerset = belongsTo(SFLayerset.self)
    public static let release = belongsTo(SFRelease.self)

    package init(
        symbolId: SFSymbol.RowID,
        layersetId: SFLayerset.RowID,
        releaseId: SFRelease.RowID
    ) {
        self.symbolId = symbolId
        self.layersetId = layersetId
        self.releaseId = releaseId
    }
}

//
//  SFSymbol.swift
//  SFSymbolsKit
//
//  Created by Noah Kamara on 25.05.2025.
//


public struct SFSymbol: SFModel {
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

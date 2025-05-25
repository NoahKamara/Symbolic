//
//  SFSymbol.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
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

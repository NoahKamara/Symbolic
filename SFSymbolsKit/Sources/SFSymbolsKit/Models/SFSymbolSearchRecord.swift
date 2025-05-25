//
//  SFSymbolSearchRecord.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import GRDB

public struct SFSymbolSearchRecord: SFRelation {
    public let id: SFSymbol.RowID
    public let name: String
    public let aliases: [String]
    public let keywords: [String]

    static let symbol = belongsTo(SFSymbol.self, key: "id")

    package init(id: SFSymbol.RowID, name: String, aliases: [String], keywords: [String]) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.keywords = keywords
    }
}

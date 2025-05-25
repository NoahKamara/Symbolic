//
//  SFCategory.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

public struct SFCategory: SFModel, Hashable {
    public typealias Key = String
    public static let databaseTableName = "categories"

    public let key: Key
    public let label: String
    public let icon: String

    public init(key: Key, label: String, icon: String) {
        self.key = key
        self.label = label
        self.icon = icon
    }
}

public struct SFSymbolCategory: SFModel {
    public static let databaseTableName = "symbol_categories"

    public let symbolId: SFSymbol.RowID
    public let categoryId: SFCategory.RowID

    public init(symbolId: SFSymbol.RowID, categoryId: SFCategory.RowID) {
        self.symbolId = symbolId
        self.categoryId = categoryId
    }
}

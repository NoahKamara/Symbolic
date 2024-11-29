//
//  SymbolConfig.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public class SymbolConfig: Codable {
    let style: SymbolStyle

    init(style: SymbolStyle = SymbolStyle()) {
        self.style = style
    }
}

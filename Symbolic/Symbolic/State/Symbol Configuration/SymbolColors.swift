//
//  SymbolColors.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import CoreGraphics
import Foundation

@Observable
class SymbolColors: Codable {
    var primary: SymbolColor
    var secondary: SymbolColor
    var tertiary: SymbolColor
    var background: SymbolBackground
    
    public init(
        primary: SymbolColor = .init(style: .primary),
        secondary: SymbolColor = .init(style: .accent),
        tertiary: SymbolColor = .init(style: nil),
        background: SymbolBackground = SymbolBackground()
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.background = background
    }
}





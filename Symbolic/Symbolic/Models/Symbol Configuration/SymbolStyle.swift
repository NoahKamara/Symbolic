//
//  SymbolStyle.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Observation
import SwiftUI

@Observable
class SymbolStyle: Codable {
    var weight: SymbolWeight = .regular
    var renderingMode: SymbolRenderingMode = .monochrome

    var primaryColor: SymbolColor
    var secondaryColor: SymbolColor
    var tertiaryColor: SymbolColor
    var background: SymbolBackground

    public init(
        weight: SymbolWeight = .regular,
        renderingMode: SymbolRenderingMode = .monochrome,
        primaryColor: SymbolColor = .init(style: .primary),
        secondaryColor: SymbolColor = .init(style: .accent),
        tertiaryColor: SymbolColor = .init(style: nil),
        backgroundStyle: SymbolBackground = .init(),
    ) {
        self.weight = weight
        self.renderingMode = renderingMode
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = tertiaryColor
        self.background = backgroundStyle
    }
}

@propertyWrapper
struct Style: DynamicProperty {
    @Environment(SymbolStyle.self)
    private var style: SymbolStyle?

    var wrappedValue: SymbolStyle {
        if let style {
            return style
        } else {
            print("Missing")
            return SymbolStyle()
        }
    }
}

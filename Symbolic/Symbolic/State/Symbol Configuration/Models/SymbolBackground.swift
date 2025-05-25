//
//  SymbolBackground.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import CoreGraphics

struct SymbolBackground: Codable {
    static let defaultCustomColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

    var style: SymbolBackgroundStyle
    var customColor: CGColor

    init(
        style: SymbolBackgroundStyle = .default,
        customColor: CGColor = defaultCustomColor
    ) {
        self.style = style
        self.customColor = customColor
    }

    func encode(to encoder: any Encoder) throws {
        try StyleOrColor.encode(
            style: style,
            defaultStyle: .default,
            customStyle: .custom,
            color: customColor,
            defaultColor: Self.defaultCustomColor,
            to: encoder
        )
    }

    init(from decoder: any Decoder) throws {
        let (style, color) = try StyleOrColor.decode(
            style: SymbolBackgroundStyle.self,
            defaultStyle: .default,
            defaultColor: Self.defaultCustomColor,
            from: decoder
        )

        self.init(style: style, customColor: color)
    }
}

enum SymbolBackgroundStyle: Hashable, Codable {
    case `default`
    case light
    case dark
    case custom
}

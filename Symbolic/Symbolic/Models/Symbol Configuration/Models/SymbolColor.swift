//
//  SymbolColor.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import CoreGraphics

struct SymbolColor: Codable {
    typealias Style = SymbolColorStyle
    static var defaultCustomColor: CGColor {
        CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    var style: Style?
    var customColor: CGColor

    init(
        style: Style?,
        customColor: CGColor = defaultCustomColor
    ) {
        self.style = style
        self.customColor = customColor
    }

    func encode(to encoder: any Encoder) throws {
        try StyleOrColor.encode(
            style: style,
            defaultStyle: .none,
            customStyle: .custom,
            color: customColor,
            defaultColor: Self.defaultCustomColor,
            to: encoder
        )
    }

    init(from decoder: any Decoder) throws {
        let (style, color) = try StyleOrColor.decode(
            style: SymbolColorStyle?.self,
            defaultStyle: .none,
            defaultColor: Self.defaultCustomColor,
            from: decoder
        )

        self.init(style: style, customColor: color)
    }
}

enum SymbolColorStyle: Hashable, Codable, CustomStringConvertible {
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case white
    case gray
    case black
    case primary
    case secondary
    case tertiary
    case quaternary
    case accent
    case custom

    var description: String {
        switch self {
        case .red: "red"
        case .orange: "orange"
        case .yellow: "yellow"
        case .green: "green"
        case .mint: "mint"
        case .teal: "teal"
        case .cyan: "cyan"
        case .blue: "blue"
        case .indigo: "indigo"
        case .purple: "purple"
        case .pink: "pink"
        case .brown: "brown"
        case .white: "white"
        case .gray: "gray"
        case .black: "black"
        case .primary: "primary"
        case .secondary: "secondary"
        case .tertiary: "tertiary"
        case .quaternary: "quaternary"
        case .accent: "accent"
        case .custom: "custom"
        }
    }
}

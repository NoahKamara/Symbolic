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
    var weight: SFSymbolWeight = .regular
    var rendering: SFSymbolRenderingMode = .monochrome
    var colors: SymbolColors = .init()
}

// MARK: Rendering Mode

enum SFSymbolRenderingMode: CaseIterable, Hashable, Codable {
    case monochrome
    case hierarchical
    case palette
    case multicolor
}

// MARK: Weight

enum SFSymbolWeight: CaseIterable, Hashable, Codable {
    case ultralight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
}

// MARK: Colors

@Observable
class SymbolColors: Codable {
    var primary: SymbolColor = .init(style: .primary)
    var secondary: SymbolColor = .init(style: .accent)
    var tertiary: SymbolColor = .init(style: nil)
}

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

    enum CodingKeys: CodingKey {
        case style
        case color
    }

    func encode(to encoder: any Encoder) throws {
        guard let style else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(style, forKey: .style)

        guard case .custom = style else {
            return
        }

        guard let hexColor = customColor.toHex() else {
            throw EncodingError.invalidValue(customColor, .init(
                codingPath: container.codingPath + [CodingKeys.color],
                debugDescription: "Could not convert CGColor to Hex String"
            ))
        }

        try container.encode(hexColor, forKey: .style)
    }

    init(from decoder: any Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let style = try container.decode(Style.self, forKey: .style)
            guard case .custom = style else {
                self.customColor = Self.defaultCustomColor
                return
            }

            let hexString = try container.decode(String.self, forKey: .color)
            guard let color = CGColor.fromHexString(hexString) else {
                throw DecodingError
                    .dataCorruptedError(
                        forKey: .color,
                        in: container,
                        debugDescription: "Invalid Hex Color \(hexString)"
                    )
            }
            self.customColor = color
        } catch let originalError {
            let container = try decoder.singleValueContainer()
            guard container.decodeNil() else {
                throw originalError
            }

            self.style = .none
            self.customColor = Self.defaultCustomColor
        }
    }
}

enum SymbolColorStyle: Hashable, Codable {
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
}

private extension CGColor {
    func toHex() -> String? {
        guard let components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

    static func fromHexString(_ value: String) -> CGColor? {
        var hexSanitized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        return CGColor(red: r, green: g, blue: b, alpha: a)
    }
}

//
//  StyleOrColor.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import Foundation
import CoreGraphics

/// A utility for encoding and decoding types that carry style and optional color information
enum StyleOrColor {
    enum CodingKeys: CodingKey {
        case style
        case color
    }
    
    /// Encodes style and color information
    ///
    /// - Parameters:
    ///   - style: style that should be encoded
    ///   - defaultStyle: the default style that should be omitted
    ///   - customStyle: the custom style that should trigger encoding of color
    ///   - color: the color that should be encoded
    ///   - defaultColor: the default color that should be omitted
    ///   - encoder: the encoder
    static func encode<Style: Equatable & Encodable>(
        style: Style,
        defaultStyle: Style,
        customStyle: Style,
        color: CGColor,
        defaultColor: CGColor,
        to encoder: any Encoder
    ) throws {
        // if the style is default we don't encode anything
        guard style != defaultStyle else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        
        // if the color is default we omit it
        guard color != defaultColor else { return }
        
        guard let hexColor = color.toHex() else {
            throw EncodingError.invalidValue(color, .init(
                codingPath: container.codingPath + [CodingKeys.color],
                debugDescription: "Could not convert CGColor to Hex String"
            ))
        }

        try container.encode(hexColor, forKey: .style)
    }
    
    /// Decoes style and color information
    /// 
    /// - Parameters:
    ///   - style: style that should be decoded
    ///   - defaultStyle: the default style if the encoded value is nil
    ///   - defaultColor: the default color if the encoded value is nil
    ///   - decoder: the decoer
    /// - Returns: a tuple of the decoded style and color
    static func decode<Style: Equatable & Decodable>(
        style: Style.Type,
        defaultStyle: Style,
        defaultColor: CGColor,
        from decoder: any Decoder
    ) throws -> (style: Style, color: CGColor) {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let style = try container.decode(Style.self, forKey: .style)
            
            guard let hexColor = try container.decodeIfPresent(String.self, forKey: .color) else {
                return (style: style, color: defaultColor)
            }
                    
            guard let color = CGColor.fromHexString(hexColor) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: decoder.codingPath+[CodingKeys.color],
                    debugDescription: "Could not convert (Hex) String '\(hexColor)' to CGColor"
                ))
            }
            
            return (style: style, color: color)
        } catch {
            if (try? decoder.singleValueContainer().decodeNil()) == true {
                return (style: defaultStyle, color: defaultColor)
            }
            
            throw error
        }
    }
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

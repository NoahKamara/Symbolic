//
//  SymbolStyleModifier.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.11.24.
//

import SwiftUI

public struct SymbolImage: View {
    let name: String
    
    @Environment(SymbolStyle.self)
    var style: SymbolStyle?
    private var fallbackStyle: SymbolStyle { style ?? .init() }
    
    public var body: some View {
        Image(systemName: name)
            .fontWeight(fallbackStyle.weight.toFontWeight())
            .symbolRenderingMode(fallbackStyle.rendering.toSymbolRenderingMode())
            .font(.system(size: 30))
            .modifier(SymbolForegroundStyle(colors: fallbackStyle.colors))
            .onAppear {
                if style == nil {
                    print("style was not set, using default")
                }
            }
    }
}

struct SymbolForegroundStyle: ViewModifier {
    let colors: SymbolColors
    
    func body(content: Content) -> some View {
        if let primary = colors.primary.style,
            let secondary = colors.secondary.style {
            if let tertiary = colors.tertiary.style {
                content
                    .foregroundStyle(
                        symbolColor(primary, customColor: colors.primary.customColor),
                        symbolColor(secondary, customColor: colors.secondary.customColor),
                        symbolColor(tertiary, customColor: colors.tertiary.customColor)
                    )
            } else {
                content
                    .foregroundStyle(
                        symbolColor(primary, customColor: colors.primary.customColor),
                        symbolColor(secondary, customColor: colors.secondary.customColor)
                    )
            }
        }
    }
}

#Preview {
    SymbolImage(name: "paintpalette.fill")
        .environment(SymbolStyle())
}

func symbolColor(_ style: SymbolColor.Style, customColor: CGColor = SymbolColor.defaultCustomColor) -> AnyShapeStyle {
    return switch style {
    case .primary: AnyShapeStyle(Color.primary)
    case .secondary: AnyShapeStyle(Color.primary.secondary)
    case .tertiary: AnyShapeStyle(Color.primary.tertiary)
    case .quaternary: AnyShapeStyle(Color.primary.quaternary)
    case .red: AnyShapeStyle(Color.red)
    case .orange: AnyShapeStyle(Color.orange)
    case .yellow: AnyShapeStyle(Color.yellow)
    case .green: AnyShapeStyle(Color.green)
    case .mint: AnyShapeStyle(Color.mint)
    case .teal: AnyShapeStyle(Color.teal)
    case .cyan: AnyShapeStyle(Color.cyan)
    case .blue: AnyShapeStyle(Color.blue)
    case .indigo: AnyShapeStyle(Color.indigo)
    case .purple: AnyShapeStyle(Color.purple)
    case .pink: AnyShapeStyle(Color.pink)
    case .brown: AnyShapeStyle(Color.brown)
    case .white: AnyShapeStyle(Color.white)
    case .gray: AnyShapeStyle(Color.gray)
    case .black: AnyShapeStyle(Color.black)
    case .accent: AnyShapeStyle(Color.accentColor)
    case .custom: AnyShapeStyle(Color(customColor))
    }
}

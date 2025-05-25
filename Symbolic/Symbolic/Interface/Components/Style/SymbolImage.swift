//
//  SymbolImage.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

public struct SymbolImage: View {
    let name: String

    @Style
    private var style: SymbolStyle

    public var body: some View {
        Image(systemName: name)
            .fontWeight(style.weight.toFontWeight())
            .symbolRenderingMode(style.rendering.toSymbolRenderingMode())
//            .font(.system(size: 30))
            .modifier(SymbolForegroundStyle(colors: style.colors))
    }
}

fileprivate struct SymbolForegroundStyle: ViewModifier {
    let colors: SymbolColors

    func body(content: Content) -> some View {
        Group {
            switch (colors.primary.style, colors.secondary.style, colors.tertiary.style) {
            case let (.some(primary), .none, .none):
                content
                    .foregroundStyle(symbolColor(primary, customColor: colors.primary.customColor))
            case let (.some(primary), .some(secondary), .none):
                content
                    .foregroundStyle(
                        symbolColor(primary, customColor: colors.primary.customColor),
                        symbolColor(secondary, customColor: colors.secondary.customColor)
                    )
            case let (.some(primary), .some(secondary), .some(tertiary)):
                content
                    .foregroundStyle(
                        symbolColor(primary, customColor: colors.primary.customColor),
                        symbolColor(secondary, customColor: colors.secondary.customColor),
                        symbolColor(tertiary, customColor: colors.tertiary.customColor)
                    )
            default:
                content
            }
        }
    }
}

#Preview {
    SymbolImage(name: "paintpalette.fill")
        .environment(SymbolStyle())
}


#Preview {
    @Previewable
    @Bindable
    var style = SymbolStyle()
    
    List {
        InspectorStyleView(style: style, selection: ["paintpalette.fill"])
            .environment(SymbolStyle())
    }
}

func symbolColor(_ style: SymbolColor.Style, customColor: CGColor = SymbolColor.defaultCustomColor) -> AnyShapeStyle {
    switch style {
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

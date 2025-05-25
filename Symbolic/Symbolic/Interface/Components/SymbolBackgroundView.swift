//
//  SymbolTile.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolBackgroundView<Content: View>: View {
    let background: SymbolBackground
    @ViewBuilder
    var content: Content

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(symbolBackground(background))

            ContainerRelativeShape()
                .stroke(.secondary)

            content
        }
        .padding(0.5)
    }
}

func symbolBackground(_ background: SymbolBackground) -> AnyShapeStyle {
#if os(macOS)
    let textBackground = Color(.textBackgroundColor)
#else
    let textBackground = Color(.systemBackground)
#endif

    return switch background.style {
    case .default: AnyShapeStyle(textBackground)
    case .light: AnyShapeStyle(textBackground.resolve(in: .light))
    case .dark: AnyShapeStyle(textBackground.resolve(in: .dark))
    case .custom: AnyShapeStyle(Color(background.customColor))
    }
}

private extension EnvironmentValues {
    static var light: EnvironmentValues {
        var values = EnvironmentValues()
        values.colorScheme = .light
        return values
    }

    static var dark: EnvironmentValues {
        var values = EnvironmentValues()
        values.colorScheme = .dark
        return values
    }
}

//
//  SymbolBackgroundPicker.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import SwiftUI

struct SymbolBackgroundPicker: View {
    @Binding
    var selection: SymbolBackground

    var body: some View {
        Menu {
            Picker("", selection: $selection.style) {
                StyleLabelView(.default)
                StyleLabelView(.light)
                StyleLabelView(.dark)
                StyleLabelView(.custom, customColor: selection.customColor)
            }
            .labelsHidden()
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(selection.style.displayName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                ColorView(style: selection.style, customColor: selection.customColor)
            }
        }
        .safeAreaInset(edge: .trailing) {
            if case .custom = selection.style {
                if case .custom = selection.style {
                    ColorPicker("", selection: $selection.customColor, supportsOpacity: false)
                        .labelsHidden()
                        .controlSize(.mini)
                }
            }
        }
    }
}

#Preview("SymbolColorPicker: Component") {
    @Previewable @State var selection = SymbolBackground(style: .default)

    Form {
        SymbolBackgroundPicker(selection: $selection)
    }
}

// MARK: StyleLabelView

private struct StyleLabelView: View {
    let style: SymbolBackgroundStyle
    let customColor: CGColor

    init(_ style: SymbolBackgroundStyle, customColor: CGColor = .black) {
        self.style = style
        self.customColor = customColor
    }

    var body: some View {
        Label {
            Text(style.displayName)
        } icon: {
            ColorView(style: style, customColor: customColor)
        }
        .labelStyle(.titleAndIcon)
        .tag(style)
    }
}

// MARK: Color View

private struct ColorView: View {
    let style: SymbolBackgroundStyle
    let customColor: CGColor

    init(style: SymbolBackgroundStyle, customColor: CGColor = .black) {
        self.style = style
        self.customColor = customColor
    }

    var body: some View {
        Image("rectangle-stroke-and-fill")
            .foregroundStyle(
                symbolBackground(.init(style: style, customColor: customColor)),
                .bar
            )
    }
}

extension SymbolBackgroundStyle {
    var displayName: String {
        switch self {
        case .default: "Default"
        case .light: "Light"
        case .dark: "Dark"
        case .custom: "Custom"
        }
    }
}

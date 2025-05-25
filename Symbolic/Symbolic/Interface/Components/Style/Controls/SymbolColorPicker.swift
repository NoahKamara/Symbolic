//
//  SymbolColorPicker.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolColorPicker: View {
    @Binding
    var selection: SymbolColor

    @FocusState
    var opacityHasFocus: Bool
    
    var body: some View {
        Menu {
            Picker(selection: $selection.style) {
                ForEach(SymbolColorStyle.hierarchical, id: \.self) { style in
                    StyleLabelView(style)
                }
            } label: {
                StyleGroupLabel(
                    title: "Hierarchical",
                    condition: \.isHierarchical,
                    selection: selection
                )
            }
            .pickerStyle(.menu)

            Picker(selection: $selection.style) {
                ForEach(SymbolColorStyle.colors, id: \.self) { style in
                    StyleLabelView(style)
                }
            } label: {
                StyleGroupLabel(
                    title: "Colors",
                    condition: \.isColor,
                    selection: selection
                )
            }
            .pickerStyle(.menu)

            ForEach(SymbolColorStyle.others, id: \.self) { style in
                Button(action: { selection.style = style }) {
                    StyleLabelView(style, customColor: selection.customColor)
                }
            }
        } label: {
            Label {
                Text(selection.style?.displayName ?? "None")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                ColorView(
                    style: selection.style ?? .custom,
                    customColor: selection.customColor
                )
            }
        }
        .safeAreaInset(edge: .trailing) {
            ZStack {
                Text("100%")
                    .foregroundStyle(.clear)
                    .padding(.horizontal, 1)
                    .fixedSize()
                    
                TextField("", value: .constant(0.5), format: .percent, prompt: Text("100%"))
                    .labelsHidden()
                    .lineLimit(1)
                    .textFieldStyle(.roundedBorder)
                    .focused($opacityHasFocus)
                    .onSubmit {
                        opacityHasFocus = false
                    }
                
            }
            .multilineTextAlignment(.center)
            .disabled(selection.style == .custom)
            .opacity(selection.style != .custom ? 1 : 0)
            .overlay(alignment: .top) {
                if case .custom = selection.style {
                    if case .custom = selection.style {
                        ColorPicker("", selection: $selection.customColor, supportsOpacity: false)
                            .labelsHidden()
                            .controlSize(.mini)
                    }
                }
            }
            .fixedSize()
        }
    }
}


#Preview("SymbolColorPicker: Component") {
    @Previewable @State var hierarchical = SymbolColor(style: .primary)
    @Previewable @State var styleColor = SymbolColor(style: .blue)
    @Previewable @State var customColor = SymbolColor(style: .custom)
    
    Form {
        SymbolColorPicker(selection: $hierarchical)
        SymbolColorPicker(selection: $styleColor)
        SymbolColorPicker(selection: $customColor)
    }
}

// MARK: StyleLabelView

private struct StyleGroupLabel: View {
    let title: String
    let condition: KeyPath<SymbolColorStyle?, Bool>
    var selection: SymbolColor

    init(title: String, condition: KeyPath<SymbolColorStyle?, Bool>, selection: SymbolColor) {
        self.title = title
        self.condition = condition
        self.selection = selection
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            ColorView(
                style: selection.style[keyPath: condition] ? selection.style! : .custom,
                customColor: .clear
            )
        }
        .labelStyle(.titleAndIcon)
    }
}

// MARK: StyleLabelView

private struct StyleLabelView: View {
    let style: SymbolColor.Style
    let customColor: CGColor

    init(_ style: SymbolColor.Style, customColor: CGColor = .black) {
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
    let style: SymbolColor.Style
    let customColor: CGColor

    init(style: SymbolColor.Style, customColor: CGColor = .black) {
        self.style = style
        self.customColor = customColor
    }

    var body: some View {
        Image("rectangle-stroke-and-fill")
            .foregroundStyle(
                symbolColor(style, customColor: customColor),
                .bar
            )
    }
}

extension Array {
    @inlinable func contains(_ element: Element?) -> Bool {
        guard let element else {
            return false
        }
        return contains(element)
    }
}

extension SymbolColor.Style {
    var displayName: String {
        switch self {
        case .red: "Red"
        case .orange: "Orange"
        case .yellow: "Yellow"
        case .green: "Green"
        case .mint: "Mint"
        case .teal: "Teal"
        case .cyan: "Cyan"
        case .blue: "Blue"
        case .indigo: "Indigo"
        case .purple: "Purple"
        case .pink: "Pink"
        case .brown: "Brown"
        case .white: "White"
        case .gray: "Gray"
        case .black: "Black"
        case .primary: "Primary"
        case .secondary: "Secondary"
        case .tertiary: "Tertiary"
        case .quaternary: "Quaternary"
        case .accent: "Accent"
        case .custom: "Custom"
        }
    }
}

// MARK: Style Groups

extension SymbolColor.Style {
    static let colors: [SymbolColor.Style] = [
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .teal,
        .cyan,
        .blue,
        .indigo,
        .purple,
        .pink,
        .brown,
        .white,
        .gray,
        .black,
    ]

    static let others: [SymbolColor.Style] = [.accent, .custom]

    static let hierarchical: [SymbolColor.Style] = [
        .primary,
        .secondary,
        .tertiary,
        .quaternary,
    ]

    var isColor: Bool { Self.colors.contains(self) }
    var isOther: Bool { Self.others.contains(self) }
    var isHierarchical: Bool { Self.hierarchical.contains(self) }
}

extension SymbolColorStyle? {
    var isColor: Bool { map { Wrapped.colors.contains($0) } ?? false }
    var isOther: Bool { map { Wrapped.others.contains($0) } ?? false }
    var isHierarchical: Bool { map { Wrapped.hierarchical.contains($0) } ?? false }
}

#if os(iOS)
extension CGColor {
    static var black: CGColor { CGColor(gray: 0, alpha: 1) }
    static var clear: CGColor { CGColor(gray: 0, alpha: 0) }
}
#endif

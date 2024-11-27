//
//  SymbolColorPicker.swift
//  Symbolic
//
//  Created by Noah Kamara on 26.11.24.
//

import SwiftUI


struct SymbolColorPicker: View {
    @Binding
    var selection: SymbolColor
    
        
    var body: some View {
        
        HStack {
            Menu {
                Picker(selection: $selection.style) {
                    ForEach(SymbolColorStyle.hierarchical, id:\.self) { style in
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
                    ForEach(SymbolColorStyle.colors, id:\.self) { style in
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
                
                ForEach(SymbolColorStyle.others, id:\.self) { style in
                    Button(action: { selection.style = style }) {
                        StyleLabelView(style, customColor: selection.customColor)
                    }
                }
            } label: {
                Label {
                    ZStack {
                        Text("Quaternary").opacity(0)
                        Text(selection.style?.displayName ?? "None")
                    }
                } icon: {
                    ColorView(
                        style: selection.style ?? .custom,
                        customColor: selection.customColor
                    )
                }
            }
            .fixedSize()
            
            TextField("100", value: .constant(1.0), format: .percent)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .disabled(selection.style == .custom)
                .opacity(selection.style != .custom ? 1 : 0)
                .overlay {
                    if case .custom = selection.style {
                        ColorPicker("", selection: $selection.customColor, supportsOpacity: false)
                            .padding(.horizontal)
                        
                    }
                }
                .fixedSize()
        }
        .menuStyle(.button)
        .buttonStyle(.bordered)
        //        .labelsHidden()
    }
}

#Preview {
    @Previewable @State var hierarchical = SymbolColor(style: .primary)
    @Previewable @State var customColor = SymbolColor(style: .custom)
    
    VStack {
        SymbolColorPicker(selection: $hierarchical)
//        SymbolColorPicker(selection: $customColor)
    }
}

// MARK: StyleLabelView
fileprivate struct StyleGroupLabel: View {
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
fileprivate struct StyleLabelView: View {
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
fileprivate struct ColorView: View {
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
        return self.contains(element)
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
        .quaternary
    ]

    var isColor: Bool { Self.colors.contains(self) }
    var isOther: Bool { Self.others.contains(self) }
    var isHierarchical: Bool { Self.hierarchical.contains(self) }
}

extension Optional {
    var isNil: Bool {
        if case .none = self { true } else { false }
    }
}
extension Optional where Wrapped == SymbolColorStyle {
    var isColor: Bool { map({ Wrapped.colors.contains($0) }) ?? false }
    var isOther: Bool { map({ Wrapped.others.contains($0) }) ?? false }
    var isHierarchical: Bool { map({ Wrapped.hierarchical.contains($0) }) ?? false }
}

#if os(iOS)
extension CGColor {
    static var black: CGColor { CGColor(gray: 0, alpha: 1) }
    static var clear: CGColor { CGColor.init(gray: 0, alpha: 0) }
}
#endif

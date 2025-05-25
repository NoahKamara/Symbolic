//
//  SymbolWeightPicker.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolWeightPicker: View {
    @Binding
    var selection: SymbolWeight

    var body: some View {
        Picker(selection: $selection) {
            ForEach(SymbolWeight.allCases, id: \.self) { weight in
                Text(weight.displayName)
            }
        } label: {
            Label(selection.displayName, systemImage: "scalemass")
        }
        .fixedSize()
        .pickerStyle(.menu)
        .menuStyle(.button)
        .buttonStyle(.bordered)
    }
}

#Preview {
    @Previewable @State var selection = SymbolWeight.regular
    SymbolWeightPicker(selection: $selection)
}

extension SymbolWeight {
    var displayName: String {
        switch self {
        case .ultralight: "Ultralight"
        case .thin: "Thin"
        case .light: "Light"
        case .regular: "Regular"
        case .medium: "Medium"
        case .semibold: "Semibold"
        case .bold: "Bold"
        case .heavy: "Heavy"
        case .black: "Black"
        }
    }

    func toFontWeight() -> Font.Weight {
        switch self {
        case .ultralight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}

//
//  SymbolRenderingModePicker.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

import SwiftUI

struct SymbolRenderingModePicker: View {
    @Binding
    var selection: SymbolRenderingMode

    var body: some View {
        Picker(selection: $selection) {
            ForEach(SymbolRenderingMode.allCases, id: \.self) { mode in
                Text(mode.displayName)
            }
        } label: {
            Label(selection.displayName, systemImage: "paintpalette")
        }
        .fixedSize()
        .pickerStyle(.menu)
        .menuStyle(.button)
        .buttonStyle(.bordered)
    }
}

#Preview {
    @Previewable @State var selection = SymbolRenderingMode.monochrome
    SymbolRenderingModePicker(selection: $selection)
}

extension SymbolRenderingMode {
    fileprivate var displayName: String {
        switch self {
        case .monochrome: "Monochrome"
        case .hierarchical: "Hierarchical"
        case .palette: "Palette"
        case .multicolor: "Multicolor"
        }
    }

    func toSymbolRenderingMode() -> SwiftUI.SymbolRenderingMode {
        switch self {
        case .monochrome: .monochrome
        case .hierarchical: .hierarchical
        case .palette: .palette
        case .multicolor: .multicolor
        }
    }
}

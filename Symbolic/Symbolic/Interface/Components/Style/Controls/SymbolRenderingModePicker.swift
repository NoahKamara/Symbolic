//
//  SymbolRenderingModePicker.swift
//  Symbolic
//
//  Created by Noah Kamara on 26.11.24.
//

import SwiftUI

import SwiftUI

struct SymbolRenderingModePicker: View {
    @Binding
    var selection: SFSymbolRenderingMode
    
    var body: some View {
        Picker(selection: $selection) {
            ForEach(SFSymbolRenderingMode.allCases, id:\.self) { mode in
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
    @Previewable @State var selection = SFSymbolRenderingMode.monochrome
    SymbolRenderingModePicker(selection: $selection)
}

extension SFSymbolRenderingMode {
    fileprivate var displayName: String {
        switch self {
        case .monochrome: "Monochrome"
        case .hierarchical: "Hierarchical"
        case .palette: "Palette"
        case .multicolor: "Multicolor"
        }
    }

    func toSymbolRenderingMode() -> SymbolRenderingMode {
        switch self {
        case .monochrome: .monochrome
        case .hierarchical: .hierarchical
        case .palette: .palette
        case .multicolor: .multicolor
        }
    }
}

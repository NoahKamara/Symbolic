//
//  SymbolGridView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

struct SymbolGridView: View {
    var symbols: [SFSymbol]
    @Binding
    var selection: Set<SFSymbol.Name>

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    .init(.adaptive(minimum: 100, maximum: 140)),
                ],
                spacing: 10
            ) {
                ForEach(symbols, id: \.name) { symbol in
                    SymbolGridItemView(
                        name: symbol.name,
                        isSelected: selection.contains(symbol.name)
                    )
                    .onTapGesture {
                        didTapSymbol(symbol.name)
                    }
#if os(macOS)
                    .modifierKeyAlternate(.command) {
                        SymbolGridItemView(
                            name: symbol.name,
                            isSelected: selection.contains(symbol.name)
                        )
                        .onTapGesture { didTapSymbol(symbol.name) }
                    }
#endif
                    .buttonStyle(.plain)
                    .containerShape(RoundedRectangle(cornerRadius: 5))
                }
            }
        }
        .contentMargins(10, for: .scrollContent)
    }

    private func didTapSymbol(_ symbolName: SFSymbol.Name, multiselect: Bool = false) {
        let isSelected = selection.contains(symbolName)

        if multiselect {
            selection.toggle(symbolName)
        } else {
            if isSelected {
                selection = []
            } else {
                selection = [symbolName]
            }
        }
    }
}

//
// #Preview {
//    SymbolGridView()
// }

extension Set {
    mutating func toggle(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
}

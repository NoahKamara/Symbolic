//
//  SymbolSelectionChangePreview.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI


struct SymbolSelectionChangePreview<Content: View>: View {
    let symbols: [String]

    @ViewBuilder
    var content: (String) -> Content
    
    init(
        symbols: [String] = defaultSymbols,
        @ViewBuilder
        content: @escaping (String) -> Content
    ) {
        self.symbols = symbols
        self.content = content
    }

    var body: some View {
        let startDate = Date.now

        TimelineView(.periodic(from: .now, by: 1)) { context in
            let index = Int(context.date.timeIntervalSince(startDate)) % symbols.count
            Form {
                content(symbols[index])
            }
        }
    }
}

fileprivate let defaultSymbols = [
    "rectangle.and.pencil.and.ellipsis",
    "person.3.sequence",
    "paintpalette",
    "paintpalette.fill",
    "person.3.sequence.fill",
    "swatchpalette",
]

#Preview("SymbolColorPicker: Inspector Integration") {
    SymbolSelectionChangePreview {
        InspectorStyleView(style: SymbolStyle(), selection: [$0])
    }
}

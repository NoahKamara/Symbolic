//
//  SymbolSelectionChangePreview.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import SwiftUI

struct SymbolSelectionChangePreview: View {
    static let defaultSymbols = [
        "rectangle.and.pencil.and.ellipsis",
        "person.3.sequence",
        "paintpalette",
        "paintpalette.fill",
        "person.3.sequence.fill",
        "swatchpalette",
    ]
    
    let style = SymbolStyle()
    let symbols: [String]
    
    init(symbols: [String] = Self.defaultSymbols) {
        self.symbols = symbols
    }
    
    var body: some View {
        let startDate = Date.now
        
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let index = Int(context.date.timeIntervalSince(startDate)) % symbols.count
            Form {
                InspectorStyleView(style: style, selection: [symbols[index]])
            }
        }
    }
}

#Preview("SymbolColorPicker: Inspector Integration") {
    SymbolSelectionChangePreview()
}


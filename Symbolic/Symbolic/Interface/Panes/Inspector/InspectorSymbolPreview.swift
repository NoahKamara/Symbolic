//
//  InspectorSymbolPreview.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Spiral
import SwiftUI

struct InspectorSymbolPreview: View {
    var symbols: [String]

    @Style
    private var style: SymbolStyle

    let maxIndex = 17

    @Namespace
    var namespace

    var body: some View {
        SymbolBackgroundView(background: style.background) {
            if let symbolName = symbols.first {
                SymbolImage(name: symbolName)
                    .font(.system(size: 85))
            }
        }
        .contentTransition(.symbolEffect(.automatic, options: .speed(2.5)))
        .frame(height: 140)
        .containerShape(.rect(cornerRadius: 10))
        .backgroundStyle(Color.white)
    }
}

#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorSymbolPreview(symbols: Array(symbols))
            .frame(height: 240)
    }
}

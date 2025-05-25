//
//  InspectorInfoTabView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct InspectorInfoView: View {
    @Environment(\.symbols)
    private var symbols

    var selection = Set<String>()

    var body: some View {
        InspectorSymbolPreview(symbols: selection.sorted())
    }
}

#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorInfoView(selection: symbols)
    }
}

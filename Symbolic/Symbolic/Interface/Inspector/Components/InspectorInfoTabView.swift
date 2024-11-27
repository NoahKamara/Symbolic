//
//  InspectorInfoTabView.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.11.24.
//

import SwiftUI

extension InspectorView {
    struct InfoTab: View {
        @Environment(\.symbols)
        private var symbols
        
        var selection = Set<String>()
        
        var body: some View {
            InspectorSymbolPreview(symbols: selection.sorted())
        }
    }
}


#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorView.InfoTab(selection: symbols)
    }
}

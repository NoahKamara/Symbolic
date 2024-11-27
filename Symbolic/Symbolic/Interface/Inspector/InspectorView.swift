//
//  InspectorView.swift
//  Symbolic
//
//  Created by Noah Kamara on 26.11.24.
//

import SwiftUI
import SFSymbolsKit
import Spiral



enum InspectorTab {
    case info
    case style
}

struct InspectorView: View {
    @Environment(\.symbols)
    private var symbols
    
    let style: SymbolStyle
    
    @Binding
    var selection: Set<SFSymbol.ID>
    
    var sortedSymbols: [SFSymbol.ID] {
        selection.sorted()
    }
    
    let maxIndex = 17
    
    @State
    var tab: InspectorTab = .style
    
    var body: some View {
        Group {
            switch tab {
            case .info:
                InfoTab(selection: selection)
                
            case .style:
                StyleTab(style: style, selection: selection)
            }
            
        }
        .frame(maxHeight: .infinity)
        .safeAreaPadding(10)
        .safeAreaInset(edge: .top) {
            Picker("", selection: $tab) {
                Image(systemName: "info.circle.fill").tag(InspectorTab.info)
                Image(systemName: "paintpalette.fill").tag(InspectorTab.style)
                Image(systemName: "play.fill") //.tab(InspectorTab.style)
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorView(style: SymbolStyle(), selection: $symbols)
    }
    .environment(SymbolStyle())
}






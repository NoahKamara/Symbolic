//
//  InspectorView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import Spiral
import SwiftUI

enum InspectorTab {
    case info
    case style
    case animate
}

struct InspectorView: View {
    @Environment(\.symbols)
    private var symbols

    let style: SymbolStyle

    @Binding
    var selection: Set<SFSymbol.Name>

    var sortedSymbols: [SFSymbol.Name] {
        selection.sorted()
    }

    @State
    var tab: InspectorTab = .style

    var body: some View {
        List {
            Group {
                switch tab {
                case .info:
                    InfoTab(selection: selection)
                    
                case .style:
                    StyleTab(style: style, selection: selection)
                    
                case .animate:
                    InfoTab(selection: selection)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(EmptyView())
        }
        .frame(maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("", selection: $tab) {
                Image(systemName: "info.circle.fill").tag(InspectorTab.info)
                Image(systemName: "paintpalette.fill").tag(InspectorTab.style)
                Image(systemName: "play.fill") // .tab(InspectorTab.style)
            }
            .pickerStyle(.segmented)
            .safeAreaPadding(10)
            .background()
        }
        .background(.background.secondary)
    }
}

#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorView(style: SymbolStyle(), selection: $symbols)
    }
    .environment(SymbolStyle())
}

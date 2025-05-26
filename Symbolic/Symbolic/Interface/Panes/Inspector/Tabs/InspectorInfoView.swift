//
//  InspectorInfoView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI
import SFSymbolsKit

struct InspectorInfoView: View {
    @Environment(\.symbols)
    private var symbols

    var selection = Set<String>()

    @State
    var detail: SFSymbolDetail? = nil
    
    var body: some View {
        InspectorSymbolPreview(symbols: selection.sorted())
        
        Group {
            if !selection.isEmpty {
                if let symbolName = selection.first {
                    Text(symbolName)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            } else {
                Text("No selection")
                    .frame(maxWidth: .infinity)
            }
        }
        
        
        if let detail, selection.first == detail.name {
            Section("Categories") {
                Text(
                    detail.categories.map(\.label),
                    format: .list(type: .and, width: .narrow)
                )
            }
            
            Section("Layersets") {
//                Text(
//                    .map(\.).map(\.description),
//                    format: .list(type: .and, width: .narrow)
//                )
                Text("\(detail.layersetAvailability)")
            }
        } else {
            Text("")
                .task(id: selection) {
                    guard let symbolName = selection.first else {
                        return
                    }
                    
                    do {
                        let detail = try await symbols.detail(for: symbolName)
                        await MainActor.run {
                            self.detail = detail
                        }
                    } catch {
                        print("Error", error)
                    }
                }
        }
    }
}

#Preview {
//    SymbolSelectionChangePreview { symbol in
//        InspectorInfoView(selection: [symbol])
//    }
    InspectorInfoView(selection: ["paintpalette"])
    .environment(SymbolStyle())
}

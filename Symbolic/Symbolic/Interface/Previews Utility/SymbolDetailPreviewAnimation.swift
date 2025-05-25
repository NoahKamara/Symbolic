//
//  SymbolDetailPreviewAnimation.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolDetailPreviewAnimation<Content: View>: View {
    @State
    private var symbols: Set<String> = []

    private let allSymbols = SymbolSelectionChangePreview.defaultSymbols.sorted()

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @ViewBuilder
    var content: (Binding<Set<String>>) -> Content

    @State
    private var forward = true

    var body: some View {
        content($symbols)
            .onReceive(timer) { _ in
                let nextIndex = symbols.count

                if forward, nextIndex < allSymbols.endIndex {
                    symbols.insert(allSymbols[nextIndex])
                } else if nextIndex >= allSymbols.startIndex {
                    symbols.remove(allSymbols[nextIndex - 1])
                    forward = symbols.isEmpty
                }
            }
    }
}

private extension Array {
    func sliced(by size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        var slices: [[Element]] = []
        for startIndex in 0...(count - size) {
            let endIndex = startIndex + size
            let slice = Array(self[startIndex..<endIndex])
            slices.append(slice)
        }

        return slices
    }
}

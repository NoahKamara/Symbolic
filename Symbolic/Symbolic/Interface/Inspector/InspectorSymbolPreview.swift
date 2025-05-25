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

    @Environment(SymbolStyle.self)
    private var style: SymbolStyle?

    let maxIndex = 17

    @Namespace
    var namespace

    var body: some View {
        TileView {
            if let symbol = symbols.first {
                Image(systemName: symbol)
                    .fontWeight(style?.weight.toFontWeight())
                    .symbolRenderingMode(style?.rendering.toSymbolRenderingMode())
                    .font(.system(size: 85))
                    .foregroundStyle(.primary)
                    .padding(.vertical)
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

struct SymbolDetailPreviewAnimation<Content: View>: View {
    @State
    private var symbols: Set<String> = []

    private let allSymbols = [
        "circle.fill",
        "rays",
        "paintpalette.fill",
        "circle",
        "star.fill",
        "paintpalette",
        "star",
        "folder.badge.person.crop",
        "figure.seated.side.air.distribution.upper",
        "auto.headlight.low.beam",
        "ipad.and.iphone",
        "visionpro.circle.fill",
        "doc.text.fill.viewfinder",
        "video.and.waveform",
        "arrow.up.right.diamond.fill",
    ].sorted()

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

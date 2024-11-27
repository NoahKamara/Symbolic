//
//  InspectorSymbolPreview.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.11.24.
//

import SwiftUI
import Spiral

struct InspectorSymbolPreview: View {
    var symbols: [String]
    
    @Environment(SymbolStyle.self)
    private var style: SymbolStyle?
    
    let maxIndex = 17
    
    @Namespace
    var namespace
    
    var body: some View {
        TileView {
            Group {
                if symbols.count > 6 {
                    SpiralView(
                        endAt: .degrees(720),
                        smoothness: 5
                    ) { index, spiralPoint in
                        if (index > 4 && maxIndex - index < symbols.count) {
                            let symbol = symbols[maxIndex - index]
                            Image(systemName: symbol)
                                .matchedGeometryEffect(id: symbol, in: namespace)
                                .font(.system(size: max(10, min(50, spiralPoint.angle.degrees / 16))))
                                .position(x: spiralPoint.point.x, y: spiralPoint.point.y)
                        }
                    }
                    .padding(.top, 20)
                } else if symbols.count > 1 {
                    LazyVGrid(columns: [.init(), .init(), .init()]) {
                        ForEach(symbols, id:\.self) { symbol in
                            Image(systemName: symbol)
                                .fontWeight(style?.weight.toFontWeight())
                                .symbolRenderingMode(style?.rendering.toSymbolRenderingMode())
                                .font(.system(size: symbols.count > 2 ? 50 : 100))
                                .foregroundStyle(.primary)
                                .padding(.vertical)
                                .matchedGeometryEffect(id: symbol, in: namespace)
                        }
                    }
                } else if let symbol = symbols.first {
                    Image(systemName: symbol)
                        .fontWeight(style?.weight.toFontWeight())
                        .symbolRenderingMode(style?.rendering.toSymbolRenderingMode())
                        .font(.system(size: 100))
                        .foregroundStyle(.primary)
                        .padding(.vertical)
                }
            }
            .contentTransition(.symbolEffect(.automatic))
            .animation(.interactiveSpring, value: symbols.count)
            .frame(height: 240)
        }
        .frame(height: 240)
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
        "arrow.up.right.diamond.fill"
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
                
                if forward && (nextIndex < allSymbols.endIndex) {
                    symbols.insert(allSymbols[nextIndex])
                } else if nextIndex >= allSymbols.startIndex {
                    symbols.remove(allSymbols[nextIndex-1])
                    forward = symbols.isEmpty
                }
            }
    }
}

fileprivate extension Array {
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


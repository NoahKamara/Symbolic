//
//  SymbolTile.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolTileView: View {
    let name: String

    @Environment(SymbolStyle.self)
    private var style: SymbolStyle?

    var body: some View {
        TileView {
            Image(systemName: name)
                .fontWeight(style?.weight.toFontWeight())
                .symbolRenderingMode(style?.rendering.toSymbolRenderingMode())
                .font(.system(size: 30))
                .foregroundStyle(.primary)
        }
        .aspectRatio(4 / 3, contentMode: .fit)
    }
}

#Preview {
    SymbolTileView(name: "circle.fill")
}

struct TileView<Content: View>: View {
    @ViewBuilder
    var content: Content

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.background)

            ContainerRelativeShape()
                .stroke(.secondary)

            content
        }
        .padding(0.5)
    }
}

#Preview {
    SymbolTileView(name: "circle.fill")
}

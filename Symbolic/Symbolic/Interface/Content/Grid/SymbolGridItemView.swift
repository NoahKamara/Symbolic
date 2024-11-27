//
//  SymbolGridItemView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct SymbolGridItemView: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            SymbolTileView(name: name)
                .overlay {
                    ContainerRelativeShape()
                        .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
                }
                .containerShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 100)

            Text(name.forceDotWrapping)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(.rect)
    }
}

#Preview {
    VStack {
        SymbolGridItemView(name: "circle.fill", isSelected: true)
        SymbolGridItemView(name: "circle.fill", isSelected: true)
    }
}

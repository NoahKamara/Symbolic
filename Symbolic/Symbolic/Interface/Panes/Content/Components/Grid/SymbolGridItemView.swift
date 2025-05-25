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
    @Style
    private var style

    var body: some View {
        VStack(spacing: 2) {
            SymbolBackgroundView(background: style.background) {
                SymbolImage(name: name)
                    .font(.system(size: 30))
            }
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                ContainerRelativeShape()
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
            }
            .frame(width: 100)

            Text(name.forceDotWrapping)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .containerShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    VStack {
        SymbolGridItemView(name: "circle.fill", isSelected: true)
        SymbolGridItemView(name: "circle.fill", isSelected: true)
    }
}

extension String {
    var forceDotWrapping: Self {
        components(separatedBy: .punctuationCharacters)
            .joined(separator: "\u{200B}.")
    }
}

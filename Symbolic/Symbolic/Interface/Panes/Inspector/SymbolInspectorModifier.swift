//
//  SymbolInspectorModifier.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

struct SymbolInspectorModifier: ViewModifier {
    @Binding
    var isPresenting: Bool

    @Binding
    var selection: Set<SFSymbol.Name>

    @Style
    private var style

    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isPresenting) {
                InspectorView(style: style, selection: $selection)
                    .navigationSplitViewColumnWidth(250)
                    .presentationDragIndicator(.hidden)
                    .presentationBackgroundInteraction(.enabled(upThrough: .large))
                    .presentationDetents([.fraction(0.3), .large])
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresenting.toggle()
                    }) {
                        Image(systemName: "sidebar.squares.trailing")
                    }
                }
            }
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(
            SymbolInspectorModifier(
                isPresenting: .constant(true),
                selection: .constant(["circle"])
            )
        )
}

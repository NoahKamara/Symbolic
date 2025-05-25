//
//  SymbolInspectorModifier.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import SwiftUI
import SFSymbolsKit

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

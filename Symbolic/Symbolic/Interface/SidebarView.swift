//
//  SidebarView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

struct SidebarView: View {
    let categories: [SFSymbolsCategory]
    @Binding
    var selection: SFSymbolsCategory.ID?

    var body: some View {
        List(selection: $selection) {
            Section("My Symbols") {}

            Section("Categories") {
                ForEach(categories, id: \.key) { category in
                    NavigationLink(value: category) {
                        Label(category.label, systemImage: category.icon)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.sidebar)
    }
}

#Preview {
    @Previewable @State var selection: SFSymbolsCategory.ID? = "all"

    SidebarView(
        categories: [
            .init(
                key: "square.grid.2x2",
                label: "all",
                icon: "All"
            ),
            .init(
                key: "sparkles",
                label: "whatsnew",
                icon: "What’s New"
            ),
            .init(
                key: "paintpalette",
                label: "multicolor",
                icon: "Multicolor"
            ),
            .init(
                key: "slider.horizontal.below.square.and.square.filled",
                label: "variablecolor",
                icon: "Variable Color"
            ),
            .init(
                key: "message",
                label: "communication",
                icon: "Communication"
            ),
        ],
        selection: $selection
    )
}

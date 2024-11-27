//
//  MainView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

struct MainView: View {
    @Bindable
    var symbols: Symbols

    var body: some View {
        NavigationSplitView {
            SidebarView(categories: symbols.categories, selection: $symbols.category)
        } detail: {
            ContentView(symbols: symbols)
        }
        .task(id: "bootstrap") {
            do {
                try await symbols.bootstrap()
            } catch {
                print("bootstrap failed")
            }
        }
    }
}

#Preview {
    @Previewable let repository = try! SymbolsRepository()
    MainView(symbols: Symbols(repository: repository))
}

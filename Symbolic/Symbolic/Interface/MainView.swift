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
    var model: AppModel

    var body: some View {
        NavigationSplitView {
            SidebarView(categories: model.categories, selection: $model.category)
                .navigationSplitViewColumnWidth(250)
        } detail: {
            ContentView(model: model)
        }
        .environment(model.style)
        .navigationSplitViewStyle(.balanced)
        .task {
            do {
                try await model.bootstrap()
                print("BOOTSTRAP SUCCESS")
            } catch {
                print("BOOTSTRAP FAILURE", error)
            }
        }
    }
}

#Preview(traits: .previewApp) {
    EnvironmentView {
        MainView(model: $0)
    }
}

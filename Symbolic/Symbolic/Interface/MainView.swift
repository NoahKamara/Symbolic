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

    @Bindable
    var style: SymbolStyle = .init()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(categories: model.categories, selection: $model.category)
            .navigationSplitViewColumnWidth(250)
        } detail: {
            DetailView(model: model)
        }
        .navigationSplitViewStyle(.balanced)
        .environment(style)
    }
}

#Preview {
    @Previewable let repository = try! SFSymbolsRepository()
    MainView(model: AppModel(repository: repository))
}

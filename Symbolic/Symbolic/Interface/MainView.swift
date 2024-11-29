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
            SidebarView(
                categories: model.categories,
                selection: $model.category
            )
        } detail: {
            ContentView(model: model)
        }
    }
}

#Preview {
    @Previewable let repository = try! SymbolsRepository()
    MainView(model: AppModel(repository: repository))
}

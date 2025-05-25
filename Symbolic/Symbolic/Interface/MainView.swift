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
            ContentView(model: model)
        }
        .navigationSplitViewStyle(.balanced)
        .environment(style)
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

extension PreviewTrait where T == Preview.ViewTraits {
    static var previewApp: Self { .modifier(PreviewAppModel()) }
}

private struct PreviewAppModel: PreviewModifier {
    static func makeSharedContext() async throws -> AppModel {
        let repository = try SFSymbolsRepository()
        let app = AppModel(repository: repository)
        try await app.bootstrap()
        return app
    }

    func body(content: Content, context: AppModel) -> some View {
        content.environment(context)
    }
}


struct EnvironmentView<Value: AnyObject & Observable, Content: View>: View {
    @Environment(Value.self)
    var value
    
    @ViewBuilder
    var content: (Value) -> Content
    
    var body: some View {
        content(value)
    }
}

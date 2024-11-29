//
//  SymbolicApp.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

@main
struct SymbolicApp: App {
    let model = AppModel(repository: try! SymbolsRepository())

    var body: some Scene {
        WindowGroup {
            MainView(model: model)
        }
    }
}

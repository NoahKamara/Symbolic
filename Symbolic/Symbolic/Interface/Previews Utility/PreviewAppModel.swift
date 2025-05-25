//
//  PreviewAppModel.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI

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

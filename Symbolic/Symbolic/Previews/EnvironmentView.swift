//
//  EnvironmentView.swift
//  Symbolic
//
//  Created by Noah Kamara on 26.05.2025.
//

import SwiftUI

struct EnvironmentView<Value: AnyObject & Observable, Content: View>: View {
    @Environment(Value.self)
    var value

    @ViewBuilder
    var content: (Value) -> Content

    init(
        of _: Value.Type = Value.self,
        @ViewBuilder
        content: @escaping (Value) -> Content
    ) {
        self.content = content
    }

    var body: some View {
        content(value)
    }
}

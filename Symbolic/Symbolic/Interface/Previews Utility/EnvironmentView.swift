//
//  EnvironmentView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct EnvironmentView<Value: AnyObject & Observable, Content: View>: View {
    @Environment(Value.self)
    var value

    @ViewBuilder
    var content: (Value) -> Content

    init(
        of _: Value.Type = Value.self,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.content = content
    }

    var body: some View {
        content(value)
    }
}

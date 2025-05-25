//
//  View+logSizeChange.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

extension View {
    func logSizeChange() -> some View {
        background {
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size) { _, newValue in
                        print(newValue)
                    }
            }
        }
    }
}

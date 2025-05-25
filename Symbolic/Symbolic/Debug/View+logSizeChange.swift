//
//  BackgroundSIze.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import SwiftUI

extension View {
    func logSizeChange() -> some View {
        self.background {
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size) { oldValue, newValue in
                        print(newValue)
                    }
            }
        }
    }
}

//
//  SymbolStyle.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Observation
import SwiftUI

@Observable
class SymbolStyle: Codable {
    var weight: SymbolWeight = .regular
    var rendering: SymbolRenderingMode = .monochrome
    var colors: SymbolColors = .init()
    var backgroundColor: SymbolColor = .init(style: nil)
}

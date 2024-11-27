//
//  SymbolConfiguration.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.11.24.
//

import Foundation


public class SymbolConfig: Codable {
    let style: SymbolStyle
    
    init(style: SymbolStyle = SymbolStyle()) {
        self.style = style
    }
}

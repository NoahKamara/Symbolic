//
//  StyleTab.swift
//  Symbolic
//
//  Created by Noah Kamara on 25.05.2025.
//

import SwiftUI

struct InspectorStyleView: View {
    @Bindable
    var style: SymbolStyle
    
    var selection: Set<String>
    
    var body: some View {
        InspectorSymbolPreview(symbols: Array(selection.sorted()))
            .environment(style)
        
        Section("Rendering") {
            LabeledContent("Font Weight") {
                SymbolWeightPicker(selection: $style.weight)
                    .labelsHidden()
            }
            
            LabeledContent("Rendering") {
                SymbolRenderingModePicker(selection: $style.rendering)
                    .labelsHidden()
            }
        }
        .symbolVariant(.fill)
        
        Section("Colors") {
            SymbolColorPicker(selection: $style.colors.primary)
            
            if style.rendering == .palette {
                SymbolColorPicker(selection: $style.colors.secondary)
                SymbolColorPicker(selection: $style.colors.tertiary)
            }
        }
        
        Section("Background") {}
    }
}

#Preview {
    SymbolDetailPreviewAnimation { $symbols in
        InspectorStyleView(
            style: .init(),
            selection: symbols
        )
    }
}


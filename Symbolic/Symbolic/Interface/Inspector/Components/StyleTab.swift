//
//  InspectorStyleTabView.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.11.24.
//

import SwiftUI


extension InspectorView {
    struct StyleTab: View {
        @Bindable
        var style: SymbolStyle
        
        var selection: Set<String>
        
        var body: some View {
            Form {
                InspectorSymbolPreview(symbols: Array(selection.sorted()))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .environment(style)
                
                Section("Font") {
                    LabeledContent("Weight") {
                        SymbolWeightPicker(selection: $style.weight)
                    }
                    
                    LabeledContent("Rendering Mode") {
                        SymbolRenderingModePicker(selection: $style.rendering)
                    }
                }
                
                Section("Colors") {
                    LabeledContent("Primary") {
                        SymbolColorPicker(selection: $style.colors.primary)
                    }
                    LabeledContent("Secondary") {
                        SymbolColorPicker(selection: $style.colors.secondary)
                    }
                    LabeledContent("Tertiary") {
                        SymbolColorPicker(selection: $style.colors.tertiary)
                    }
                }
            }
            .containerShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}




#Preview {
    let style = SymbolStyle()
    SymbolDetailPreviewAnimation { $symbols in
        InspectorView.StyleTab(style: style, selection: symbols)
    }
}
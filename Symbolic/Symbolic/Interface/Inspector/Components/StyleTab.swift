//
//  StyleTab.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
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
                    LabeledContent("Primary") {
                        SymbolColorPicker(selection: $style.colors.primary)
                    }

                    if style.rendering == .palette {
                        LabeledContent("Secondary") {
                            SymbolColorPicker(selection: $style.colors.secondary)
                        }

                        LabeledContent("Tertiary") {
                            SymbolColorPicker(selection: $style.colors.tertiary)
                        }
                    }
                }

                Section("Background") {}
            }
        }
    }
}

#Preview {
    let style = SymbolStyle()
    SymbolDetailPreviewAnimation { $symbols in
        InspectorView.StyleTab(style: style, selection: symbols)
    }
}

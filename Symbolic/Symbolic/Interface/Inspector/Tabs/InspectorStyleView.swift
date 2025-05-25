//
//  InspectorStyleView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
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
                SymbolRenderingModePicker(selection: $style.renderingMode)
                    .labelsHidden()
            }
        }
        .symbolVariant(.fill)

        Section("Colors") {
            SymbolColorPicker(selection: $style.primaryColor)

            if style.renderingMode == .palette {
                SymbolColorPicker(selection: $style.secondaryColor)
                SymbolColorPicker(selection: $style.tertiaryColor)
            }
        }

        Section("Background") {
            SymbolBackgroundPicker(selection: $style.background)
        }
    }
}

#Preview {
    Text("Hi")
        .inspector(isPresented: .constant(true)) {
            SymbolDetailPreviewAnimation { $symbols in
                InspectorStyleView(
                    style: .init(),
                    selection: symbols
                )
            }
        }
}

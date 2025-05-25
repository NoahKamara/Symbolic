//
//  ContentToolbar.swift
//  Symbolic
//
//  Created by Noah Kamara on 26.05.2025.
//


import SwiftUI

struct ContentToolbar: ViewModifier {
    @Bindable
    var style: SymbolStyle
    
    func body(content: Content) -> some View {
        content
            .toolbar(id: "style") {
                ToolbarItem(id: "symbol-styling") {
                    StylingToolbar(style: style)
                }
                .defaultCustomization(.visible)
                
                ToolbarItem(id: "symbol-weight") {
                    SymbolWeightPicker(selection: $style.weight)
                }
                
                ToolbarItem(id: "symbol-rendering-mode") {
                    SymbolRenderingModePicker(selection: $style.renderingMode)
                }
            }

        #if os(macOS)
            .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
        #else
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        #endif
            .toolbarRole(.editor)
            .toolbarTitleDisplayMode(.inline)
    }
}

fileprivate struct StylingToolbar: View {
    @Bindable
    var style: SymbolStyle
    
    @State
    var isPresented: Bool = false
    
    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Image(systemName: "swatchpalette.fill")
        }
        .popover(
            isPresented: $isPresented
//            attachmentAnchor: <#T##PopoverAttachmentAnchor#>,
//            arrowEdge: <#T##Edge?#>
        ) {
            Form {
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
            .frame(minWidth: 300, maxWidth: 300, minHeight: 350)
            .presentationCompactAdaptation(.popover)
        }
    }
}


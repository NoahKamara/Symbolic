//
//  ContentView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import SFSymbolsKit
import SwiftUI




struct ContentView: View {
    let symbols: Symbols

    @State
    private var categoryDetail: SFSymbolsCategory? = nil

    @State
    var selectedSymbols: Set<SFSymbol.ID> = []

    @Bindable
    var style: SymbolStyle = SymbolStyle()
    
    @State
    private var isPresentingInspector: Bool = true
    
    func categoryLabel(_ key: SFSymbolsCategory.ID) -> String {
        let category = symbols.categories.first(where: { $0.key == key })
        return category?.label ?? "Unknown"
    }

    var body: some View {
        SymbolGridView(
            symbols: symbols.result,
            selection: $selectedSymbols
        )
        .environment(style)
        .navigationTitle(categoryLabel(symbols.category ?? "all"))
#if os(macOS)
            .navigationSubtitle(Text("\(symbols.result.count) Symbols"))
#else
            .toolbar {
                ToolbarItem(placement: .status) {
                    Text("\(symbols.result.count) Symbols")
                        .contentTransition(.numericText(value: Double(symbols.result.count)))
                }
            }
#endif
            .toolbar(id: "tools") {
                ToolbarItem(id: "weight-picker", placement: .primaryAction) {
                    SymbolWeightPicker(selection: $style.weight)
                }
                ToolbarItem(id: "rendering-mode-picker", placement: .primaryAction) {
                    SymbolRenderingModePicker(selection: $style.rendering)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isPresentingInspector.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.squares.trailing")
                    }
                }
            }
            .inspector(isPresented: $isPresentingInspector) {
                InspectorView(style: style, selection: $selectedSymbols)
            }
            .onAppear {
                self.selectedSymbols.insert("circle")
            }
    }
}

#Preview {
    @Previewable let symbols = Symbols(repository: try! SymbolsRepository())
    NavigationStack {
        ContentView(symbols: symbols)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .task { try? await symbols.bootstrap() }
}

extension String {
    var forceDotWrapping: Self {
        components(separatedBy: .punctuationCharacters)
            .joined(separator: "\u{200B}.")
    }
}

extension Set {
    mutating func toggle(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
}


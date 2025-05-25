//
//  DetailView.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Combine
import SFSymbolsKit
import SwiftUI

@Observable
class AppModel {
    let repository: SFSymbolsRepository

    let style = SymbolStyle()
    
    @MainActor
    var category: SFCategory.Key? = nil {
        didSet { triggerUpdate() }
    }

    @MainActor
    var searchTerm: String = "" {
        didSet { triggerUpdate() }
    }

    var isShowingSidebar: Bool = false
    
    var selectedSymbols: Set<SFSymbol.Name> = []

    @MainActor
    private(set) var result: [SFSymbol] = []

    var categories: [SFCategory] = []

    init(repository: SFSymbolsRepository) {
        self.repository = repository
        self.updateCancellable = updateSubject
            .eraseToAnyPublisher()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.global())
            .sink { request in
                Task {
                    let results = try await self.repository.symbols(for: request)
                    await MainActor.run {
                        self.result = results
                    }
                }
            }
    }

    private let updateSubject = PassthroughSubject<SymbolsFetchRequest, Never>()
    private var updateCancellable: (any Cancellable)!

    func bootstrap() async throws {
        guard categories.isEmpty else {
            print("Already")
            return
        }
        try await update()

        let categories = try await repository.categories()
        
        await MainActor.run {
            self.categories = categories
        }
    }

    private func update() async throws {
        let result = try await repository.symbols()
        await MainActor.run {
            didUpdateResult(result)
        }
    }

    @MainActor
    private func triggerUpdate() {
        let request = SymbolsFetchRequest(
            searchTerm: !searchTerm.isEmpty ? searchTerm : nil,
            category: category != "all" ? category : nil
        )
        updateSubject.send(request)
    }

    @MainActor
    private func didUpdateResult(_ symbols: [SFSymbol]) {
        let request = SymbolsFetchRequest(
            category: category != "all" ? category : nil
        )
        updateSubject.send(request)
    }
}

struct ContentView: View {
    @Bindable
    var model: AppModel

    @State
    private var isPresentingInspector: Bool = true

    private func categoryLabel(forKey key: String) -> String {
        guard let category = model.categories.first(where: { $0.key == key }) else {
            return "All Symbols"
        }

        return category.label
    }

    @Style
    var style
    
    @State
    private var availableWidth: CGFloat = 0
    
    var body: some View {
        SymbolGridView(
            symbols: model.result,
            selection: $model.selectedSymbols
        )
        .navigationTitle(categoryLabel(forKey: model.category ?? "all"))
#if os(macOS)
        .navigationSubtitle(Text("\(model.result.count) Symbols"))
#endif
        .onChange(of: isPresentingInspector) { _, newValue in
            model.isShowingSidebar = !newValue
        }
        .modifier(
            SymbolInspectorModifier(
                isPresenting: $isPresentingInspector,
                selection: $model.selectedSymbols
            )
        )
        .toolbar {
            @Bindable var style = self.style
            
            ToolbarItem(id: "weight-picker", placement: .primaryAction) {
                SymbolWeightPicker(selection: $style.weight)
            }
            ToolbarItem(id: "rendering-mode-picker", placement: .primaryAction) {
                SymbolRenderingModePicker(selection: $style.renderingMode)
            }
        }
    }
}

@propertyWrapper
struct Style: DynamicProperty {
    @Environment(SymbolStyle.self)
    private var style: SymbolStyle?
    
    var wrappedValue: SymbolStyle {
        if let style {
            return style
        } else {
            
            print("Missing")
            return SymbolStyle()
        }
    }
}

#Preview {
    @Previewable let model = AppModel(repository: try! SFSymbolsRepository())
    NavigationStack {
        ContentView(model: model)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(SymbolStyle())
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

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

    @MainActor
    var category: SFCategory.Key? = nil {
        didSet { triggerUpdate() }
    }

    @MainActor
    var searchTerm: String = "" {
        didSet { triggerUpdate() }
    }

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

        Task { try await self.bootstrap() }
    }

    private let updateSubject = PassthroughSubject<SymbolsFetchRequest, Never>()
    private var updateCancellable: (any Cancellable)!

    private func bootstrap() async throws {
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
        print("trigger")
        updateSubject.send(request)
    }
}

struct DetailView: View {
    let model: AppModel

    @State
    private var categoryDetail: SFCategory? = nil

    @State
    var selectedSymbols: Set<SFSymbol.Name> = []

    @Bindable
    var style: SymbolStyle = .init()

    @State
    private var isPresentingInspector: Bool = true

    private func categoryLabel(forKey key: String) -> String {
        guard let category = model.categories.first(where: { $0.key == key }) else {
            return "All Symbols"
        }

        return category.label
    }

    var body: some View {
        SymbolGridView(
            symbols: model.result,
            selection: $selectedSymbols
        )
        .environment(style)
        .navigationTitle(categoryLabel(forKey: model.category ?? "all"))
#if os(macOS)
        .navigationSubtitle(Text("\(model.result.count) Symbols"))
#else
            .toolbar {
                ToolbarItem(placement: .status) {
                    Text("\(model.result.count) Symbols")
                        .contentTransition(.numericText(value: Double(model.result.count)))
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
                    .presentationDetents([.height(300), .medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            .onAppear {
                selectedSymbols.insert("circle")
            }
    }
}

#Preview {
    @Previewable let model = AppModel(repository: try! SFSymbolsRepository())
    NavigationStack {
        DetailView(model: model)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

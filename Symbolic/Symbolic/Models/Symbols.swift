//
//  Symbols.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

import Combine
import GRDB
import SFSymbolsKit
import SwiftUI

@Observable
class Symbols {
    let repository: SFSymbolsRepository

    @MainActor
    var category: SFCategory.Key? = "all" {
        didSet { triggerUpdate() }
    }

    @MainActor
    private(set) var categories: [SFCategory] = []

    @MainActor
    public private(set) var result: [SFSymbol] = []

    private let updateSubject = PassthroughSubject<SymbolsFetchRequest, Never>()
    private var updateCancellable: (any Cancellable)!

    @MainActor
    private func triggerUpdate() {
        let request = SymbolsFetchRequest(
            category: category != "all" ? category : nil
        )
        updateSubject.send(request)
    }

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

    func bootstrap() async throws {
        let categories = try await repository.categories()

        await MainActor.run {
            self.categories = categories
        }

        try await update()
    }

    func update() async throws {
        print("update")
        let result = try await repository.symbols()
        await MainActor.run {
            self.result = result
        }
    }
}

extension SFSymbolsRepository {
    init(named name: String = "symbols", in bundle: Bundle = .main) throws {
        let path = bundle.path(forResource: name, ofType: "sqlite")!
        try self.init(at: path, createIfMissing: false)
    }
}

extension EnvironmentValues {
    @Entry var symbols = try! SFSymbolsRepository()
}

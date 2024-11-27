//
//  SFSymbolsExtract.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import ArgumentParser
import Foundation
import GRDB
import SFSymbolsKit

@main
struct SFSymbolsExtract: AsyncParsableCommand {
    @Option
    var output: String = "./symbols.sqlite"

    @Option
    var inMemory: Bool = false

    @Option(completion: .file(extensions: ["app"]))
    var app: String = "/Applications/SF Symbols.app"

    mutating func run() async throws {
        let app = SFSymbolsApp(appUrl: URL(filePath: app))

        let repository = if inMemory {
            try SymbolsRepository(database: DatabaseQueue())
        } else {
            try SymbolsRepository(at: output)
        }

        try await app.extract(into: repository)
    }
}

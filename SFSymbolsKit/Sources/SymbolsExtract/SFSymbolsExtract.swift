//
//  SFSymbolsExtract.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import ArgumentParser
import Foundation
import SFSymbolsKit

@main
struct SFSymbolsExtract: AsyncParsableCommand {
    @Option
    var output: String = "./symbols.sqlite"

    @Option(completion: .file(extensions: ["app"]))
    var app: String = "/Applications/SF Symbols.app"

    mutating func run() async throws {
        let app = SFSymbolsApp(appUrl: URL(filePath: app))
        let output = URL(filePath: output)

        let repository = try PersistedSymbolsRepository(at: output.path())

        try await app.extract(into: repository)
    }
}

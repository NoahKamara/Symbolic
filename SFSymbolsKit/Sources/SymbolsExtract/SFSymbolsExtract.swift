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

        if !inMemory {
            let fm = FileManager.default

            if fm.fileExists(atPath: output) {
                print("File \(output) already exists. Overwrite? [y/N]:")

                if readLine(strippingNewline: true).map({ $0.lowercased() == "y" }) ?? false {
                    print("Overriding existing file...")
                    try fm.removeItem(atPath: output)
                } else {
                    print("Ok. exiting...")
                    return
                }
            }
        }

        let repository = if inMemory {
            try SFSymbolsRepository(database: DatabaseQueue())
        } else {
            try SFSymbolsRepository(at: output)
        }

        try await app.extract(into: repository)
    }
}

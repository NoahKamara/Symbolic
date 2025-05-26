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

    @Option(help: "override existing file")
    var force: Bool = false
    
    mutating func run() async throws {
        let app = SFSymbolsApp(appUrl: URL(filePath: app))

        let repository: SFSymbolsRepository
        
        if inMemory {
            repository = try SFSymbolsRepository(database: DatabaseQueue(), createIfMissing: true)
        } else {
            let fm = FileManager.default
            let fileExists = fm.fileExists(atPath: output)
            
            
            if fileExists {
                if !force {
                    print("File \(output) already exists. Overwrite? [y/N]:")
                    
                    if readLine(strippingNewline: true).map({ $0.lowercased() == "y" }) != true {
                        print("Ok. exiting...")
                        return
                    }
                }
                
                print("Deleting existing file...")
                try fm.removeItem(atPath: output)
            }
            
            repository = try SFSymbolsRepository(at: output, createIfMissing: true)
        }

        try await app.extract(into: repository)
    }
}

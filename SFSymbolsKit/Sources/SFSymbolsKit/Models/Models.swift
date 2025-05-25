//
//  Models.swift
//  Symbolic
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import GRDB

public protocol SFModel: Sendable, Codable, FetchableRecord, PersistableRecord {
    typealias RowID = Int64
}


public protocol SFRelation: Sendable, Codable, FetchableRecord, PersistableRecord {}

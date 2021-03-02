//
//  PathFilter.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct PathFilter: Hashable {
    private let id = UUID()

    private let predicate: (PathDecoder.DeferredSingleValueContainer) throws -> Bool

    init<Key: Decodable, Value: Decodable>(predicate: @escaping (Key, Value) throws -> Bool) {
        self.predicate = { container in
            try predicate(
                try container.decodeFromKey(),
                try container.decodeFromValue()
            )
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: PathFilter, rhs: PathFilter) -> Bool {
        lhs.id == rhs.id
    }

    internal func callAsFunction(_ container: PathDecoder.DeferredSingleValueContainer) throws -> Bool {
        try predicate(container)
    }
}

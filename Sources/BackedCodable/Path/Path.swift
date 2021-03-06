//
//  Path.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct Path: Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    public static func ?? (lhs: Path, rhs: Path) -> Path {
        Path(storage: lhs.storage + rhs.storage)
    }

    private var storage: [[PathComponent]] = [[]]

    internal var components: [[PathComponent]] {
        storage
    }

    public static let root = Path()

    private init() {}

    internal init(storage: [[PathComponent]]) {
        self.storage = storage
    }

    public init(_ components: PathComponent...) {
        self.storage = [components]
    }

    public init(stringLiteral value: String) {
        guard value.isEmpty == false else {
            self.init()
            return
        }
        self.init(.key(value))
    }

    public func appending(_ pathComponents: PathComponentConvertible...) -> Path {
        var copy = self
        for i in copy.storage.indices {
            for component in pathComponents {
                copy.storage[i].append(component.makePathComponent())
            }
        }
        return copy
    }

    public var description: String {
        let componentsDescription = components
            .map { $0.map(\.description).joined(separator: ", ") }
            .map { "[\($0)]" }
            .joined(separator: " OR ")

        return "Path(\(componentsDescription))"
    }
}

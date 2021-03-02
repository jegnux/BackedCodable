//
//  Path.swift
//
//  Created by Jérôme Alves.
//

import Foundation

@dynamicMemberLookup
public struct Path: Hashable, CustomStringConvertible {
    public static func ?? (lhs: Path, rhs: Path) -> Path {
        Path(storage: .or(lhs.storage, rhs.storage))
    }

    private var storage: PathStorage = .root

    internal var components: [[PathComponent]] {
        storage.components
    }

    private init(storage: PathStorage) {
        self.storage = storage
    }

    internal init(_ components: PathComponent...) {
        for component in components {
            storage.append(component)
        }
    }

    internal func appending(_ pathComponent: PathComponent) -> Path {
        var copy = self
        copy.storage.append(pathComponent)
        return copy
    }

    public static subscript(dynamicMember value: KeyPath<Path, Path>) -> Path {
        Path()[keyPath: value]
    }

    public subscript(dynamicMember key: String) -> Path {
        appending(.key(key))
    }

    public subscript(key: String) -> Path {
        appending(.key(key))
    }

    public subscript(index: Int) -> Path {
        appending(.index(index))
    }

    public subscript(pathComponent: PathComponent) -> Path {
        appending(pathComponent)
    }

    public var description: String {
        "Path(\(components.map(\.description).joined(separator: ", ")))"
    }
}

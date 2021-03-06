//
//  PathComponent.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public enum PathComponent: Hashable, CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    case key(String)
    case index(Int)
    case allKeys
    case allValues
    case keys(PathFilter)
    case values(PathFilter)

    public init(stringLiteral value: String) {
        self = .key(value)
    }

    public init(integerLiteral value: Int) {
        self = .index(value)
    }

    public static func keys<Key: Decodable, Value: Decodable>(where predicate: @escaping (Key, Value) throws -> Bool) -> PathComponent {
        .keys(PathFilter(predicate: predicate))
    }

    public static func keys<Key: Decodable>(where predicate: @escaping (Key) throws -> Bool) -> PathComponent {
        .keys { (key, _: EmptyDecodable) in
            try predicate(key)
        }
    }

    public static func values<Key: Decodable, Value: Decodable>(where predicate: @escaping (Key, Value) throws -> Bool) -> PathComponent {
        .values(PathFilter(predicate: predicate))
    }

    public static func values<Value: Decodable>(where predicate: @escaping (Value) throws -> Bool) -> PathComponent {
        .values { (_: EmptyDecodable, value) in
            try predicate(value)
        }
    }

    public var description: String {
        switch self {
        case .key(let key): return "key(\"\(key)\")"
        case .index(let index): return "index(\(index))"
        case .allKeys: return "allKeys"
        case .allValues: return "allValues"
        case .keys: return "keys(where: ...)"
        case .values: return "values(where: ...)"
        }
    }

    var isKeyValue: Bool {
        switch self {
        case .allKeys, .allValues, .keys, .values:
            return true
        default:
            return false
        }
    }
}

public protocol PathComponentConvertible {
    func makePathComponent() -> PathComponent
}

extension String: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        PathComponent(stringLiteral: self)
    }
}

extension Int: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        PathComponent(integerLiteral: self)
    }
}

extension PathComponent: PathComponentConvertible {
    public func makePathComponent() -> PathComponent {
        self
    }
}

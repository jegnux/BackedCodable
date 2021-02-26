import Foundation

public struct PathFilter {
    let predicate: (DeferredSingleValueContainer) throws -> Bool
    
    init<Key: Decodable, Value: Decodable>(predicate: @escaping (Key, Value) throws -> Bool) {
        self.predicate = { container in
            try predicate(
                try container.decodeFromKey(),
                try container.decodeFromValue()
            )
        }
    }
}

public enum PathComponent: CustomStringConvertible {
    case key(String)
    case index(Int)
    case allKeys
    case allValues
    case keys(PathFilter)
    case values(PathFilter)

    public static func keys<Key: Decodable, Value: Decodable>(where predicate: @escaping (Key, Value) throws -> Bool) -> PathComponent {
        .keys(PathFilter(predicate: predicate))
    }

    public static func keys<Key: Decodable>(where predicate: @escaping (Key) throws -> Bool) -> PathComponent {
        .keys { (key, _: AnyDecodableValue) in
            try predicate(key)
        }
    }
    
    public static func values<Key: Decodable, Value: Decodable>(where predicate: @escaping (Key, Value) throws -> Bool) -> PathComponent {
        .values(PathFilter(predicate: predicate))
    }
    
    public static func values<Value: Decodable>(where predicate: @escaping (Value) throws -> Bool) -> PathComponent {
        .values { (_: AnyDecodableValue, value) in
            try predicate(value)
        }
    }

    public var description: String {
        switch self {
        case .key(let key):     return "key(\"\(key)\")"
        case .index(let index): return "index(\(index))"
        case .allKeys:          return "allKeys"
        case .allValues:        return "allValues"
        case .keys:             return "keys(where: ...)"
        case .values:           return "values(where: ...)"
        }
    }
}

@dynamicMemberLookup
public struct Path {
    private(set) public var components: [PathComponent] = []

    internal init(_ components: PathComponent...) {
        self.components = components
    }
    
    public func appending(_ pathComponent: PathComponent) -> Path {
        var copy = self
        copy.components.append(pathComponent)
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

}

import Foundation

public enum PathComponent: CustomStringConvertible {
    case key(String)
    case index(Int)
    case allKeys
    case allValues
    
    public var description: String {
        switch self {
        case .key(let key):     return "key(\"\(key)\")"
        case .index(let index): return "index(\(index))"
        case .allKeys:          return "allKeys"
        case .allValues:        return "allValues"
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

extension Path {
    public subscript(getter: (_PathComponentFactory) -> PathComponent) -> Path {
        appending(getter(_PathComponentFactory()))
    }
}

public struct _PathComponentFactory {
    fileprivate init() {}
}

postfix operator *
public postfix func * (_ lhs: _PathComponentFactory) -> PathComponent {
    .allValues
}

postfix operator ~
public postfix func ~ (_ lhs: _PathComponentFactory) -> PathComponent {
    .allKeys
}

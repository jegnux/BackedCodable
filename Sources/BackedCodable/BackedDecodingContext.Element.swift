import Foundation

typealias UnkeyedCollection = [DeferredSingleValueContainer]

extension BackedDecodingContext {
    enum Element {
        case decoder(Decoder)
        case singleValue(SingleValueDecodingContainer)
        case unkeyed(UnkeyedDecodingContainer)
        case keyed(KeyedDecodingContainer<BackedCodingKey>)
        case unkeyedCollection(UnkeyedCollection)
    }
}

extension BackedDecodingContext.Element {
    
    // MARK: - Closest containers
    
    public func closestSingleValueContainer() throws -> SingleValueDecodingContainer {
        switch self {
        case let .decoder(decoder):
            return try decoder.singleValueContainer()
        case let .singleValue(container):
            return container
        case .unkeyed, .keyed, .unkeyedCollection:
            throw BackedError.invalidPath
        }
    }
    
    public func closestUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch self {
        case let .decoder(decoder):
            return try decoder.unkeyedContainer()
        case let .unkeyed(container):
            return container
        case .keyed, .singleValue, .unkeyedCollection:
            throw BackedError.invalidPath
        }
    }
    
    public func closestKeyedContainer() throws -> KeyedDecodingContainer<BackedCodingKey> {
        switch self {
        case let .decoder(decoder):
            return try decoder.container(keyedBy: BackedCodingKey.self)
        case var .unkeyed(container):
            return try container.nestedContainer(keyedBy: BackedCodingKey.self)
        case let .keyed(container):
            return container
        case .singleValue, .unkeyedCollection:
            throw BackedError.invalidPath
        }
    }
    
    public func closestUnkeyedCollection() throws -> UnkeyedCollection {
        switch self {
        case .unkeyedCollection(let collection):
            return collection
        default:
            throw BackedError.invalidPath
        }
    }
    
    // MARK: - Keyed access

    public func nestedUnkeyedContainer(forKey key: String) throws -> UnkeyedDecodingContainer {
        try closestKeyedContainer().nestedUnkeyedContainer(forKey: .string(key))
    }
    
    public func nestedKeyedContainer(forKey key: String) throws -> KeyedDecodingContainer<BackedCodingKey> {
        try closestKeyedContainer().nestedContainer(keyedBy: BackedCodingKey.self, forKey: .string(key))
    }
        
    public func decode<T: Decodable>(forKey key: String) throws -> T {
        try closestKeyedContainer().decode(T.self, forKey: .string(key))
    }
    
    // MARK: - Unkeyed access

    public func nestedUnkeyedContainer(at index: Int) throws -> UnkeyedDecodingContainer {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedUnkeyedContainer()
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw BackedError.invalidPath
    }

    public func nestedKeyedContainer(at index: Int) throws -> KeyedDecodingContainer<BackedCodingKey> {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedContainer(keyedBy: BackedCodingKey.self)
            } else {
                _ = try container.decode(AnyDecodableValue.self)
            }
        }
        throw BackedError.invalidPath
    }

    public func decode<T: Decodable>(at index: Int) throws -> T {
        do {
            let container = try closestUnkeyedCollection()
            return try container[index].decode()
        } catch {
            var container = try closestUnkeyedContainer()
            var currentIndex = 0
            while container.isAtEnd == false {
                defer { currentIndex += 1 }
                if currentIndex == index {
                    return try container.decode(T.self)
                } else {
                    _ = try container.decode(AnyDecodableValue.self)
                }
            }
            throw BackedError.invalidPath
        }
    }

    // MARK: - Direct access

    public func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        var container = try closestUnkeyedContainer()
        return try container.nestedUnkeyedContainer()
    }
    
    public func nestedKeyedContainer() throws -> KeyedDecodingContainer<BackedCodingKey> {
        var container = try closestUnkeyedContainer()
        return try container.nestedContainer(keyedBy: BackedCodingKey.self)
    }
    
    public func decode<T: Decodable>() throws -> T {
        do {
            var container = try closestUnkeyedContainer()
            return try container.decode(T.self)
        } catch {
            return try closestSingleValueContainer().decode(T.self)
        }
    }
    
    // MARK: - Unkeyed Collection
    
    public func nestedUnkeyedCollection(_ kind: DeferredSingleValueContainer.Kind, filter: PathFilter? = nil) throws -> UnkeyedCollection {
        let container = try closestKeyedContainer()
        var collection = container.allKeys.sorted().map { key in
            DeferredSingleValueContainer(kind: kind, key: key, container: container)
        }
        if let filter = filter {
            try collection.removeAll { container -> Bool in
                try filter.predicate(container) == false
            }
        }
        return collection
    }
}

struct DeferredSingleValueContainer {
    enum Kind {
        case decodeFromKey
        case decodeFromValue
    }
    
    init(kind: DeferredSingleValueContainer.Kind, key: BackedCodingKey, container: KeyedDecodingContainer<BackedCodingKey>) {
        self.kind = kind
        self.key = key
        self.container = container
    }

    private let kind: Kind
    private let key: BackedCodingKey
    private let container: KeyedDecodingContainer<BackedCodingKey>
        
    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        switch kind {
        case .decodeFromKey:
            return try decodeFromKey()
        case .decodeFromValue:
            return try decodeFromValue()
        }
    }
    
    func decodeFromKey<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        guard let value = (key.stringValue as? T) ?? (key.intValue as? T) else {
            throw BackedError.invalidPath
        }
        return value
    }

    func decodeFromValue<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        try container.decode(T.self, forKey: key)
    }
}

import Foundation

public final class BackedDecodingContext {
    init(decoder: Decoder, path: Path, options: BackedOptions, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) throws {
        self.decoder = decoder
        self.pathComponents = path.components
        self.options = options
        self.dateDecodingStrategy = dateDecodingStrategy
        
        var elements: [Element] = [.decoder(decoder)]
        var lastElement: Element { elements.last! }
        
        for (current, next) in zip(path.components, path.components.dropFirst()) {
            switch (current, next) {
            case (.key(let key), .key),
                 (.key(let key), .allKeys),
                 (.key(let key), .allValues),
                 (.key(let key), .keys),
                (.key(let key), .values):
                elements.append(
                    .keyed(try lastElement.nestedKeyedContainer(forKey: key))
                )
            case (.key(let key), .index):
                elements.append(
                    .unkeyed(try lastElement.nestedUnkeyedContainer(forKey: key))
                )
            case (.index(let index), .key),
                (.index(let index), .allKeys),
                (.index(let index), .allValues),
                (.index(let index), .keys),
                (.index(let index), .values):
                elements.append(
                    .keyed(try lastElement.nestedKeyedContainer(at: index))
                )
            case (.index(let index), .index):
                elements.append(
                    .unkeyed(try lastElement.nestedUnkeyedContainer(at: index))
                )
             
            case (.allKeys, .index):
                elements.append(
                    .unkeyedCollection(try lastElement.nestedUnkeyedCollection(.decodeFromKey))
                )

            case (.keys(let filter), .index):
                elements.append(
                    .unkeyedCollection(try lastElement.nestedUnkeyedCollection(.decodeFromKey, filter: filter))
                )
                
            case (.allValues, .index):
                elements.append(
                    .unkeyedCollection(try lastElement.nestedUnkeyedCollection(.decodeFromValue))
                )
                
            case (.values(let filter), .index):
                elements.append(
                    .unkeyedCollection(try lastElement.nestedUnkeyedCollection(.decodeFromValue, filter: filter))
                )

            default:
                throw BackedError.invalidPath
                
            }
        }
        
        self.elements = elements
    }

    let pathComponents: [PathComponent]
    let elements: [Element]

    public let decoder: Decoder
    public let options: BackedOptions
    public let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    func decode<T: Decodable>(_ type: T.Type = T.self, kind: DeferredSingleValueContainer.Kind, filter: PathFilter? = nil) throws -> [T] {
        let collection = try elements.last!.nestedUnkeyedCollection(kind, filter: filter)
        if options.contains(.lossy) {
            return collection.compactMap { try? $0.decode() }
        } else {
            return try collection.map { try $0.decode() }
        }
    }

    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> [T] {
        switch pathComponents.last {
        case .allKeys:
            return try decode(type, kind: .decodeFromKey)
        case .allValues:
            return try decode(type, kind: .decodeFromValue)
        case .keys(let filter):
            return try decode(type, kind: .decodeFromKey, filter: filter)
        case .values(let filter):
            return try decode(type, kind: .decodeFromValue, filter: filter)
        default:
            throw BackedError.invalidPath
        }
    }

    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        switch pathComponents.last {
        case let .key(key):
            return try elements.last!.decode(forKey: key)
        case let .index(index):
            return try elements.last!.decode(at: index)
        case .allKeys, .allValues, .keys, .values, nil:
            throw BackedError.invalidPath
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch pathComponents.last {
        case let .key(key):
            return try elements.last!.nestedUnkeyedContainer(forKey: key)
        case let .index(index):
            return try elements.last!.nestedUnkeyedContainer(at: index)
        case nil:
            return try elements.last!.closestUnkeyedContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath
        }
    }
    
    func keyedContainer() throws -> KeyedDecodingContainer<BackedCodingKey> {
        switch pathComponents.last {
        case let .key(key):
            return try elements.last!.nestedKeyedContainer(forKey: key)
        case let .index(index):
            return try elements.last!.nestedKeyedContainer(at: index)
        case nil:
            return try elements.last!.closestKeyedContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath
        }
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        switch pathComponents.last {
        case .key, .index:
            throw BackedError.invalidPath
        case nil:
            return try elements.last!.closestSingleValueContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath
        }
    }
}

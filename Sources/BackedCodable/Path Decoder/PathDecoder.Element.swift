//
//  PathDecoder.Element.swift
//
//  Created by Jérôme Alves.
//

import Foundation

extension PathDecoder {
    public typealias SingleValueContainer = SingleValueDecodingContainer
    public typealias KeyedContainer = KeyedDecodingContainer<PathCodingKey>
    public typealias UnkeyedContainer = UnkeyedDecodingContainer
    typealias UnkeyedCollection = [DeferredSingleValueContainer]
}

extension PathDecoder {
    enum Element {
        case decoder(Decoder)
        case singleValue(SingleValueContainer)
        case unkeyed(UnkeyedContainer)
        case keyed(KeyedContainer)
        case unkeyedCollection(UnkeyedCollection)
    }
}

extension Array where Element == PathDecoder.Element {
    // MARK: - Closest containers

    func closestSingleValueContainer() throws -> PathDecoder.SingleValueContainer {
        for element in reversed() {
            switch element {
            case .decoder(let decoder):
                return try decoder.singleValueContainer()
            case .singleValue(let container):
                return container
            case .unkeyed, .keyed, .unkeyedCollection:
                continue
            }
        }
        throw BackedError.invalidPath()
    }

    func closestUnkeyedContainer() throws -> PathDecoder.UnkeyedContainer {
        for element in reversed() {
            switch element {
            case .decoder(let decoder):
                return try decoder.unkeyedContainer()
            case .unkeyed(let container):
                return container
            case .keyed, .singleValue, .unkeyedCollection:
                continue
            }
        }
        throw BackedError.invalidPath()
    }

    func closestKeyedContainer() throws -> PathDecoder.KeyedContainer {
        for element in reversed() {
            switch element {
            case .decoder(let decoder):
                return try decoder.container(keyedBy: PathCodingKey.self)
            case .unkeyed(var container):
                return try container.nestedContainer(keyedBy: PathCodingKey.self)
            case .keyed(let container):
                return container
            case .singleValue, .unkeyedCollection:
                continue
            }
        }
        throw BackedError.invalidPath()
    }

    func closestUnkeyedCollection() throws -> PathDecoder.UnkeyedCollection {
        for element in reversed() {
            switch element {
            case .unkeyedCollection(let collection):
                return collection
            default:
                continue
            }
        }
        throw BackedError.invalidPath()
    }

    // MARK: - Keyed access

    func nestedUnkeyedContainer(forKey key: String) throws -> PathDecoder.UnkeyedContainer {
        try closestKeyedContainer().nestedUnkeyedContainer(forKey: .string(key))
    }

    func nestedKeyedContainer(forKey key: String) throws -> PathDecoder.KeyedContainer {
        try closestKeyedContainer().nestedContainer(keyedBy: PathCodingKey.self, forKey: .string(key))
    }

    func decode<T: Decodable>(forKey key: String) throws -> T {
        try closestKeyedContainer().decode(T.self, forKey: .string(key))
    }

    // MARK: - Unkeyed access

    func nestedUnkeyedContainer(at index: Int) throws -> PathDecoder.UnkeyedContainer {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedUnkeyedContainer()
            } else {
                _ = try container.decode(EmptyDecodable.self)
            }
        }
        throw BackedError.invalidPath()
    }

    func nestedKeyedContainer(at index: Int) throws -> PathDecoder.KeyedContainer {
        var container = try closestUnkeyedContainer()
        var currentIndex = 0
        while container.isAtEnd == false {
            defer { currentIndex += 1 }
            if currentIndex == index {
                return try container.nestedContainer(keyedBy: PathCodingKey.self)
            } else {
                _ = try container.decode(EmptyDecodable.self)
            }
        }
        throw BackedError.invalidPath()
    }

    func decode<T: Decodable>(at index: Int) throws -> T {
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
                    _ = try container.decode(EmptyDecodable.self)
                }
            }
            throw BackedError.invalidPath()
        }
    }

    // MARK: - Direct access

    func nestedUnkeyedContainer() throws -> PathDecoder.UnkeyedContainer {
        var container = try closestUnkeyedContainer()
        return try container.nestedUnkeyedContainer()
    }

    func nestedKeyedContainer() throws -> PathDecoder.KeyedContainer {
        var container = try closestUnkeyedContainer()
        return try container.nestedContainer(keyedBy: PathCodingKey.self)
    }

    func decode<T: Decodable>() throws -> T {
        do {
            var container = try closestUnkeyedContainer()
            return try container.decode(T.self)
        } catch {
            return try closestSingleValueContainer().decode(T.self)
        }
    }

    // MARK: - Unkeyed Collection

    func nestedUnkeyedCollection(_ kind: PathDecoder.DeferredSingleValueContainer.Kind, filter: PathFilter? = nil) throws -> PathDecoder.UnkeyedCollection {
        let container = try closestKeyedContainer()
        var collection = container.allKeys.sorted().map { key in
            PathDecoder.DeferredSingleValueContainer(kind: kind, key: key, container: container)
        }
        if let filter = filter {
            try collection.removeAll { container -> Bool in
                try filter(container) == false
            }
        }
        return collection
    }
}

extension PathDecoder {
    struct DeferredSingleValueContainer {
        enum Kind {
            case decodeFromKey
            case decodeFromValue
        }

        init(kind: DeferredSingleValueContainer.Kind, key: PathCodingKey, container: PathDecoder.KeyedContainer) {
            self.kind = kind
            self.key = key
            self.container = container
        }

        private let kind: Kind
        private let key: PathCodingKey
        private let container: PathDecoder.KeyedContainer

        func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
            switch kind {
            case .decodeFromKey:
                return try decodeFromKey()
            case .decodeFromValue:
                return try decodeFromValue()
            }
        }

        func decodeFromKey<T: Decodable>(_ type: T.Type = T.self) throws -> T {
            do {
                if let int = key.intValue {
                    return try sharedDecoder.decode(Box<T>.self, from: sharedEncoder.encode(IntBox(value: int))).value
                }
                return try sharedDecoder.decode(Box<T>.self, from: sharedEncoder.encode(StringBox(value: key.stringValue))).value
            } catch {
                return try container.decode(T.self, forKey: key)
            }
        }

        func decodeFromValue<T: Decodable>(_ type: T.Type = T.self) throws -> T {
            try container.decode(T.self, forKey: key)
        }
    }
}

private let sharedEncoder = JSONEncoder()
private let sharedDecoder = JSONDecoder()

private struct StringBox: Encodable {
    let value: String
}

private struct IntBox: Encodable {
    let value: Int
}

private struct Box<T: Decodable>: Decodable {
    let value: T
}

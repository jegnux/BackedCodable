//
//  PathDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public final class PathDecoder {
    init(decoder: Decoder, pathComponents: [PathComponent], options: BackingDecoderOptions) throws {
        guard pathComponents.isEmpty == false else {
            throw BackedError.invalidPath()
        }
        self.decoder = decoder
        self.pathComponents = pathComponents
        self.options = options

        var elements: [Element] = [.decoder(decoder)]

        for (current, next) in zip(pathComponents, pathComponents.dropFirst()) {
            switch (current, next) {
            case (.key(let key), .key),
                 (.key(let key), .allKeys),
                 (.key(let key), .allValues),
                 (.key(let key), .keys),
                 (.key(let key), .values):
                elements.append(
                    .keyed(try elements.nestedKeyedContainer(forKey: key))
                )
            case (.key(let key), .index):
                elements.append(
                    .unkeyed(try elements.nestedUnkeyedContainer(forKey: key))
                )
            case (.index(let index), .key),
                 (.index(let index), .allKeys),
                 (.index(let index), .allValues),
                 (.index(let index), .keys),
                 (.index(let index), .values):
                elements.append(
                    .keyed(try elements.nestedKeyedContainer(at: index))
                )
            case (.index(let index), .index):
                elements.append(
                    .unkeyed(try elements.nestedUnkeyedContainer(at: index))
                )

            case (.allKeys, .index):
                elements.append(
                    .unkeyedCollection(try elements.nestedUnkeyedCollection(.decodeFromKey))
                )

            case (.keys(let filter), .index):
                elements.append(
                    .unkeyedCollection(try elements.nestedUnkeyedCollection(.decodeFromKey, filter: filter))
                )

            case (.allValues, .index):
                elements.append(
                    .unkeyedCollection(try elements.nestedUnkeyedCollection(.decodeFromValue))
                )

            case (.values(let filter), .index):
                elements.append(
                    .unkeyedCollection(try elements.nestedUnkeyedCollection(.decodeFromValue, filter: filter))
                )

            default:
                throw BackedError.invalidPath()
            }
        }

        self.elements = elements
    }

    let pathComponents: [PathComponent]
    let elements: [Element]

    public let decoder: Decoder
    public let options: BackingDecoderOptions

    func decode<T: Decodable>(_ type: T.Type = T.self, kind: DeferredSingleValueContainer.Kind, filter: PathFilter? = nil) throws -> [T] {
        let collection = try elements.nestedUnkeyedCollection(kind, filter: filter)
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
            throw BackedError.invalidPath()
        }
    }

    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        switch pathComponents.last {
        case .key(let key):
            return try elements.decode(forKey: key)
        case .index(let index):
            return try elements.decode(at: index)
        case .allKeys, .allValues, .keys, .values, nil:
            return try elements.decode()
//            throw BackedError.invalidPath()
        }
    }

    func unkeyedContainer() throws -> UnkeyedContainer {
        switch pathComponents.last {
        case .key(let key):
            return try elements.nestedUnkeyedContainer(forKey: key)
        case .index(let index):
            return try elements.nestedUnkeyedContainer(at: index)
        case nil:
            return try elements.closestUnkeyedContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath()
        }
    }

    func keyedContainer() throws -> KeyedContainer {
        switch pathComponents.last {
        case .key(let key):
            return try elements.nestedKeyedContainer(forKey: key)
        case .index(let index):
            return try elements.nestedKeyedContainer(at: index)
        case nil:
            return try elements.closestKeyedContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath()
        }
    }

    func singleValueContainer() throws -> SingleValueContainer {
        switch pathComponents.last {
        case .key, .index:
            throw BackedError.invalidPath()
        case nil:
            return try elements.closestSingleValueContainer()
        case .allKeys, .allValues, .keys, .values:
            throw BackedError.invalidPath()
        }
    }
}

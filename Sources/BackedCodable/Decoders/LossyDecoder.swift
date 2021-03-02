//
//  LossyDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

protocol LossyDecodable: Decodable {
    associatedtype Element: Decodable
    static func backed(by array: [Element]) -> Self
    mutating func add(_ lossyElement: Lossy<Element>)
}

extension Array: LossyDecodable where Element: Decodable {
    static func backed(by array: [Element]) -> Self {
        array
    }

    mutating func add(_ lossyElement: Lossy<Element>) {
        guard let value = lossyElement.value else { return }
        append(value)
    }
}

extension Set: LossyDecodable where Element: Decodable {
    static func backed(by array: [Element]) -> Self {
        Set(array)
    }

    mutating func add(_ lossyElement: Lossy<Element>) {
        guard let value = lossyElement.value else { return }
        insert(value)
    }
}

public struct Lossy<Value: Decodable>: Decodable {
    public let value: Value?
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            value = try container.decode(Value.self)
        } catch {
            self.value = nil
        }
    }
}

enum LossyDecoder {
    static func decode<Value: LossyDecodable>(from decoder: PathDecoder) throws -> Value {
        guard decoder.options.contains(.lossy) else {
            return try decoder.decode(Value.self)
        }
        var container = try decoder.unkeyedContainer()

        var elements: Value = .backed(by: [])
        while !container.isAtEnd {
            elements.add(try container.decode(Lossy<Value.Element>.self))
        }
        return elements
    }
}

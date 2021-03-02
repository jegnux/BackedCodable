//
//  PathCodingKey.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct PathCodingKey: CodingKey, ExpressibleByStringLiteral, Comparable {
    public static func < (lhs: PathCodingKey, rhs: PathCodingKey) -> Bool {
        switch (lhs.intValue, rhs.intValue) {
        case (let lhs?, let rhs?):
            return lhs < rhs
        case (.some, nil):
            return true
        case (nil, .some):
            return false
        case (nil, nil):
            return lhs.stringValue < rhs.stringValue
        }
    }

    public var stringValue: String
    public var intValue: Int?

    public static func string(_ string: String) -> PathCodingKey {
        PathCodingKey(stringValue: string)
    }

    public static func index(_ index: Int) -> PathCodingKey {
        PathCodingKey(intValue: index)
    }

    public init(stringLiteral value: StaticString) {
        self.stringValue = value.description
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

//
//  BackedCodingKey.swift
//  
//
//  Created by Jérôme Alves on 25/02/2021.
//

import Foundation

public struct BackedCodingKey: CodingKey, ExpressibleByStringLiteral, Comparable {
    public static func < (lhs: BackedCodingKey, rhs: BackedCodingKey) -> Bool {
        switch (lhs.intValue, rhs.intValue) {
        case let (lhs?, rhs?):
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
    
    public static func string(_ string: String) -> BackedCodingKey {
        BackedCodingKey(stringValue: string)
    }

    public static func index(_ index: Int) -> BackedCodingKey {
        BackedCodingKey(intValue: index)
    }

    public init(stringLiteral value: StaticString) {
        stringValue = value.description
    }
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}


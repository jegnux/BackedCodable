//
//  Backed+ConditionalProtocolConformances.swift
//
//  Created by Jérôme Alves.
//

import Foundation

extension Backed: Equatable where Value: Equatable {
    public static func == (lhs: Backed<Value>, rhs: Backed<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public static func == (lhs: Value, rhs: Backed<Value>) -> Bool {
        lhs == rhs.wrappedValue
    }

    public static func == (lhs: Backed<Value>, rhs: Value) -> Bool {
        lhs.wrappedValue == rhs
    }
}

extension Backed: Comparable where Value: Comparable {
    public static func < (lhs: Backed<Value>, rhs: Backed<Value>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }

    public static func < (lhs: Value, rhs: Backed<Value>) -> Bool {
        lhs < rhs.wrappedValue
    }

    public static func < (lhs: Backed<Value>, rhs: Value) -> Bool {
        lhs.wrappedValue < rhs
    }
}

extension Backed: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

//
//  File.swift
//  
//
//  Created by Jérôme Alves on 25/02/2021.
//

import Foundation

extension Backed: Equatable where T: Equatable {
    public static func == (lhs: Backed<T>, rhs: Backed<T>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public static func == (lhs: T, rhs: Backed<T>) -> Bool {
        lhs == rhs.wrappedValue
    }

    public static func == (lhs: Backed<T>, rhs: T) -> Bool {
        lhs.wrappedValue == rhs
    }
}

extension Backed: Comparable where T: Comparable {
    public static func < (lhs: Backed<T>, rhs: Backed<T>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }

    public static func < (lhs: T, rhs: Backed<T>) -> Bool {
        lhs < rhs.wrappedValue
    }

    public static func < (lhs: Backed<T>, rhs: T) -> Bool {
        lhs.wrappedValue < rhs
    }
}

extension Backed: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

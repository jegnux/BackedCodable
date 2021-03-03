//
//  BackedDecodable.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public protocol BackedDecodable: Decodable {
    init()
}

extension BackedDecodable {
    public init(from decoder: Decoder) throws {
        self = .init()
        for (path, decodable) in decodablePaths {
            try decodable.decodeWrappedValue(at: path, from: decoder)
        }
    }

    private var decodablePaths: [(Path, WrappedDecodable)] {
        Mirror(reflecting: self).children.compactMap { key, value in
            guard var key = key, let decodable = value as? WrappedDecodable else {
                return nil
            }
            if key.hasPrefix("_") {
                key.remove(at: key.startIndex)
            }
            return (Path(.key(key)), decodable)
        }
    }
}

extension Backed: WrappedDecodable {}
private protocol WrappedDecodable: AnyObject {
    func decodeWrappedValue(at path: Path?, from decoder: Decoder) throws
}

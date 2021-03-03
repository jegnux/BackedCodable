//
//  Decoder+PathDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

extension Decoder {
    func decode<T>(_ type: T.Type = T.self, at path: Path, options: BackingDecoderOptions = [], decode: (PathDecoder) throws -> T) throws -> T {

        for components in path.components {
            do {
                let context = try PathDecoder(
                    decoder: self,
                    pathComponents: components,
                    options: options
                )
                return try decode(context)
            } catch {}
        }

        throw BackedError.invalidPath(path)
    }

    public func decode<T>(_ type: T.Type = T.self, at path: Path, options: BackingDecoderOptions = []) throws -> T where T: ElementDecodable {
        try decode(type, at: path, options: options) {
            try T.decode(from: $0)
        }
    }

    public func decode<T>(_ type: T.Type = T.self, at path: Path, options: BackingDecoderOptions = []) throws -> T where T: Decodable {
        try decode(type, at: path, options: options) {
            try $0.decode()
        }
    }
}

public protocol ElementDecodable: Decodable {
    static func decode(from decoder: PathDecoder) throws -> Self
}

extension Optional: ElementDecodable where Wrapped: ElementDecodable {
    public static func decode(from decoder: PathDecoder) throws -> Self {
        try Wrapped.decode(from: decoder)
    }
}

extension Array: ElementDecodable where Element: Decodable {
    public static func decode(from decoder: PathDecoder) throws -> [Element] {
        if decoder.pathComponents.last?.isKeyValue == true {
            return try decoder.decode(Element.self)
        } else {
            return try LossyDecoder.decode(from: decoder)
        }
    }
}

extension Set: ElementDecodable where Element: Decodable {
    public static func decode(from decoder: PathDecoder) throws -> Set<Element> {
        if decoder.pathComponents.last?.isKeyValue == true {
            return Set(try decoder.decode(Element.self) as [Element])
        } else {
            return try LossyDecoder.decode(from: decoder)
        }
    }
}

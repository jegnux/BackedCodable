//
//  BackingDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct BackingDecoder<Value> {
    public let decode: (Decoder, BackingDecoderContext) throws -> Value

    public init(decode: @escaping (Decoder, BackingDecoderContext) throws -> Value) {
        self.decode = decode
    }

    public func decode(from decoder: Decoder, context: BackingDecoderContext) throws -> Value {
        try decode(decoder, context)
    }
}

public func ?? <Value>(lhs: BackingDecoder<Value>, rhs: BackingDecoder<Value>) -> BackingDecoder<Value> {
    BackingDecoder<Value> { decoder, context in
        do {
            return try lhs.decode(from: decoder, context: context)
        } catch {
            return try rhs.decode(from: decoder, context: context)
        }
    }
}

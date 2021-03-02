//
//  Backed.swift
//
//  Created by Jérôme Alves.
//

import Foundation

@propertyWrapper
public final class Backed<Value> {
    public let decoder: BackingDecoder<Value>
    public let context: BackingDecoderContext

    private var _wrappedValue: Value?
    public var wrappedValue: Value {
        guard let wrappedValue = _wrappedValue else {
            fatalError("\(type(of: self)).wrappedValue has been used before being initialized. This is a programming error.")
        }
        return wrappedValue
    }

    public var projectedValue: Backed<Value> {
        self
    }

    public init(_ path: Path?, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decoder: BackingDecoder<Value>) {
        self._wrappedValue = defaultValue
        self.context = .init(path: path ?? Path(), options: options)
        self.decoder = decoder
    }

    func decodeWrappedValue(at inferredPath: Path, from decoder: Decoder) throws {
        do {
            _wrappedValue = try self.decoder.decode(
                from: decoder,
                context: context.withInferredPath(inferredPath)
            )
        } catch {
            if _wrappedValue == nil {
                throw error
            }
        }
    }
}

extension Backed {
    public convenience init(wrappedValue value: Value) {
        self.init(value)
    }

    public convenience init(_ value: Value) {
        self.init(nil, defaultValue: value, options: [], decoder: BackingDecoder { _, _ in value })
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decode: @escaping (Decoder, BackingDecoderContext) throws -> Value) {
        let decoder = BackingDecoder<Value>(decode: decode)
        self.init(path, defaultValue: defaultValue, options: options, decoder: decoder)
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decode: @escaping (Decoder) throws -> Value) {
        self.init(path, defaultValue: defaultValue, options: options) { decoder, _ in
            try decode(decoder)
        }
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = []) where Value: ElementDecodable {
        self.init(path, defaultValue: defaultValue, options: options) { decoder, context in
            try decoder.decode(Value.self, at: context.path, options: context.options)
        }
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = []) where Value: Decodable {
        self.init(path, defaultValue: defaultValue, options: options) { decoder, context in
            try decoder.decode(Value.self, at: context.path, options: context.options)
        }
    }
}

extension Backed: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        _wrappedValue?.description ?? "nil"
    }
}

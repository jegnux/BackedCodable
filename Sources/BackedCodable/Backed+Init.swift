//
//  Backed+Init.swift
//
//  Created by Jérôme Alves.
//

import Foundation

extension Backed {
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

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], strategy: DateDecodingStrategy) where Value == Date {
        self.init(path, defaultValue: defaultValue, options: options, decoder: .date(strategy: strategy))
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value = nil, options: BackingDecoderOptions = [], strategy: DateDecodingStrategy) where Value == Date? {
        self.init(path, defaultValue: defaultValue, options: options, decoder: .date(strategy: strategy))
    }
}

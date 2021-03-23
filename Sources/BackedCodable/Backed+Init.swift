//
//  Backed+Init.swift
//
//  Created by Jérôme Alves.
//

import Foundation

extension Backed {

    /// Initializes a new wrapper for the given property declaring the decoding strategy.
    /// - Parameters:
    ///   - path: The `Path` where the property should be decoded. Use `nil` to infer the key from the property name. Default is `nil`.
    ///   - defaultValue: The value to use if the decoding fails for any reason (null value, missing key, invalid type). Default is `nil`.
    ///   - options: Options for decoding the given property. See `BackedDecoderOptions`.
    ///   - decoder: The decoder used to actually decode the given property.
    public convenience init<T>(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decoder backingDecoder: BackingDecoder<T>) where Value == T? {
        self.init(path, defaultValue: defaultValue, options: options, decoder: BackingDecoder { decoder, context -> T? in
            try backingDecoder.decode(from: decoder, context: context)
        })
    }
    
    /// Initializes a new wrapper for the given property declaring the decoding strategy.
    /// - Parameters:
    ///   - path: The `Path` where the property should be decoded. Use `nil` to infer the key from the property name. Default is `nil`.
    ///   - defaultValue: The value to use if the decoding fails for any reason (null value, missing key, invalid type). Default is `nil`.
    ///   - options: Options for decoding the given property. See `BackedDecoderOptions`.
    ///   - decode: A closure to decode the value using the given `decoder` and `context`.
    ///   - decoder: The decoder to read data from.
    ///   - context: The context describing where the data should be read from.
    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decode: @escaping (_ decoder: Decoder, _ context: BackingDecoderContext) throws -> Value) {
        let decoder = BackingDecoder<Value>(decode: decode)
        self.init(path, defaultValue: defaultValue, options: options, decoder: decoder)
    }

    /// Initializes a new wrapper for the given property declaring the decoding strategy.
    /// - Parameters:
    ///   - path: The `Path` where the property should be decoded. Use `nil` to infer the key from the property name. Default is `nil`.
    ///   - defaultValue: The value to use if the decoding fails for any reason (null value, missing key, invalid type). Default is `nil`.
    ///   - options: Options for decoding the given property. See `BackedDecoderOptions`.
    ///   - decode: A closure to decode the value using the given `decoder` and `context`.
    ///   - decoder: The decoder to read data from.
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

    public convenience init(_ path: Path? = nil, defaultValue: Value? = nil, options: BackingDecoderOptions = [], strategy: DateDecodingStrategy) where Value == [Date] {
        self.init(path, defaultValue: defaultValue, options: options, decoder: .dates(strategy: strategy))
    }

    public convenience init(_ path: Path? = nil, defaultValue: Value = nil, options: BackingDecoderOptions = [], strategy: DateDecodingStrategy) where Value == [Date]? {
        self.init(path, defaultValue: defaultValue, options: options, decoder: .dates(strategy: strategy))
    }
}

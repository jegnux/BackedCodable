//
//  Backed.swift
//
//  Created by Jérôme Alves.
//

import Foundation

@propertyWrapper
public final class Backed<Value> {
    
    /// Initializes a new wrapper for the given property declaring the decoding strategy.
    /// - Parameters:
    ///   - path: The `Path` where the property should be decoded. Use `nil` to infer the key from the property name. Default is `nil`.
    ///   - defaultValue: The value to use if the decoding fails for any reason (null value, missing key, invalid type). If `nil`, the decoding error will be thrown. Default is `nil`.
    ///   - options: Options for decoding the given property. See `BackedDecoderOptions`.
    ///   - decoder: The decoder used to actually decode the given property.
    public init(
        _ path: Path? = nil,
        defaultValue: Value? = nil,
        options: BackingDecoderOptions = [],
        decoder: BackingDecoder<Value>
    ) {
        self._wrappedValue = defaultValue ?? extractDefaultValue()
        self.context = .init(givenPath: path, options: options)
        self.decoder = decoder
    }

    public let decoder: BackingDecoder<Value>
    public let context: BackingDecoderContext

    private var hasBeenDecoded = false
    private var _initialValue: Value? = extractDefaultValue()
    private var _wrappedValue: Value?
    
    public var wrappedValue: Value {
        let value: Value? = hasBeenDecoded
            ? (_wrappedValue ?? _initialValue)
            : _initialValue
        guard let wrappedValue = value else {
            fatalError("\(type(of: self)).wrappedValue has been used before being initialized. This is a programming error.")
        }
        return wrappedValue
    }

    public var projectedValue: Value? {
        get { _initialValue }
        set { _initialValue = newValue }
    }

    public func decodeWrappedValue(at inferredPath: Path? = nil, from decoder: Decoder) throws {
        hasBeenDecoded = true
        do {
            _wrappedValue = try self.decoder.decode(
                from: decoder,
                context: context.withInferredPath(inferredPath ?? Path())
            )
        } catch {
            if (_wrappedValue ?? _initialValue) == nil {
                throw error
            }
        }
    }
}

extension Backed: CustomStringConvertible {
    public var description: String {
        String(describing: (_wrappedValue ?? _initialValue) as Any? ?? "nil")
    }
}

extension Backed: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let value = _wrappedValue ?? _initialValue {
            if let x = value as? CustomDebugStringConvertible {
                return x.debugDescription
            } else if let x = value as? CustomStringConvertible {
                return x.description
            }
        }
        return (_wrappedValue ?? _initialValue).debugDescription
    }
}

private func extractDefaultValue<T>(from type: T.Type = T.self) -> T? {
    guard let type = T.self as? ExpressibleByNilLiteral.Type,
          let none = type.init(nilLiteral: ()) as? T
    else {
        return nil
    }
    return .some(none)
}

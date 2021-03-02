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
        guard let wrappedValue = _wrappedValue ?? extractDefaultValue() else {
            fatalError("\(type(of: self)).wrappedValue has been used before being initialized. This is a programming error.")
        }
        return wrappedValue
    }

    public var projectedValue: Backed<Value> {
        self
    }

    public init(_ path: Path?, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decoder: BackingDecoder<Value>) {
        self._wrappedValue = defaultValue ?? extractDefaultValue()
        self.context = .init(path: path ?? Path(), options: options)
        self.decoder = decoder
    }

    public convenience init<T>(_ path: Path?, defaultValue: Value? = nil, options: BackingDecoderOptions = [], decoder backingDecoder: BackingDecoder<T>) where Value == T? {
        self.init(path, defaultValue: defaultValue, options: options, decoder: BackingDecoder { decoder, context -> T? in
            try backingDecoder.decode(from: decoder, context: context)
        })
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

extension Backed: CustomStringConvertible {
    public var description: String {
        String(describing: _wrappedValue as Any? ?? "nil")
    }
}

extension Backed: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let value = _wrappedValue {
            if let x = value as? CustomDebugStringConvertible {
                return x.debugDescription
            } else if let x = value as? CustomStringConvertible {
                return x.description
            }
        }
        return _wrappedValue.debugDescription
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

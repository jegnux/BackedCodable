//
//  DateDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

private let iso8601DateFormatter = ISO8601DateFormatter()

public enum DateDecodingStrategy {
    /// Defer to `Decoder` for decoding. This is the default strategy.
    case deferredToDecoder

    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    case secondsSince1970

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    case millisecondsSince1970

    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601

    /// Decode the `Date` as a string parsed by the given formatter.
    case formatted(DateFormatter)

    /// Decode the `Date` as a custom value decoded by the given closure.
    case custom((Decoder) throws -> Date)
}

private enum DateDecoder {
    static func decode(from decoder: Decoder, context: BackingDecoderContext, strategy: DateDecodingStrategy) throws -> Date {
        try decoder.decode(at: context.path, options: context.options) { context in
            switch strategy {
            case .deferredToDecoder:
                return try context.decode(Date.self)
            case .secondsSince1970:
                return Date(
                    timeIntervalSince1970: try context.decode(Double.self)
                )
            case .millisecondsSince1970:
                return Date(
                    timeIntervalSince1970: try context.decode(Double.self) / 1000
                )
            case .iso8601:
                return try iso8601DateFormatter.date(
                    from: try context.decode(String.self)
                ) ?? .missingValue()
            case .formatted(let formatter):
                return try formatter.date(
                    from: try context.decode(String.self)
                ) ?? .missingValue()
            case .custom(let handler):
                return try handler(context.decoder)
            }
        }
    }
}

extension Backed {
    public convenience init(
        _ path: Path? = nil,
        defaultValue: Value? = nil,
        options: BackingDecoderOptions = [],
        strategy: DateDecodingStrategy
    ) where Value == Date {
        self.init(path, defaultValue: defaultValue, options: options) { decoder, context in
            try DateDecoder.decode(from: decoder, context: context, strategy: strategy)
        }
    }
}

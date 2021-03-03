//
//  DateDecoder.swift
//
//  Created by Jérôme Alves.
//

import Foundation

private let iso8601DateFormatter = ISO8601DateFormatter()

public struct DateDecodingStrategy {
    private let decode: (PathDecoder) throws -> Date

    private init(_ decode: @escaping (PathDecoder) throws -> Date) {
        self.decode = decode
    }

    /// Defer to `Decoder` for decoding. This is the default strategy.
    public static let deferredToDecoder = DateDecodingStrategy { decoder in
        try decoder.decode(Date.self)
    }

    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    public static let secondsSince1970 = DateDecodingStrategy { decoder in
        Date(timeIntervalSince1970: try decoder.decode(TimeInterval.self))
    }

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    public static let millisecondsSince1970 = DateDecodingStrategy { decoder in
        Date(timeIntervalSince1970: try decoder.decode(TimeInterval.self) / 1000)
    }

    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    public static let iso8601 = DateDecodingStrategy { decoder in
        try iso8601DateFormatter.date(
            from: try decoder.decode(String.self)
        ) ?? .missingValue()
    }

    /// Decode the `Date` as a string parsed by the given formatter.
    public static func formatted(_ formatter: DateFormatter) -> DateDecodingStrategy {
        DateDecodingStrategy { decoder in
            try formatter.date(
                from: try decoder.decode(String.self)
            ) ?? .missingValue()
        }
    }

    /// Decode the `Date` as a custom value decoded by the given closure.
    public static func custom(_ decode: @escaping (PathDecoder) throws -> Date) -> DateDecodingStrategy {
        DateDecodingStrategy(decode)
    }

    fileprivate func decode(from decoder: PathDecoder) throws -> Date {
        try decode(decoder)
    }
}

extension BackingDecoder {
    static func date(strategy: DateDecodingStrategy) -> BackingDecoder<Date> {
        BackingDecoder<Date> { (decoder, context) -> Date in
            try decoder.decode(at: context.path, options: context.options) { decoder in
                try strategy.decode(from: decoder)
            }
        }
    }

    static func dates(strategy: DateDecodingStrategy) -> BackingDecoder<[Date]> {
        BackingDecoder<[Date]> { (decoder, context) -> [Date] in
            try decoder.decode(at: context.path, options: context.options) { pathDecoder in
                let count: Int
                if pathDecoder.pathComponents.last?.isKeyValue == true {
                    count = try pathDecoder.unkeyedCollection().count
                } else {
                    count = try pathDecoder.unkeyedContainer().count ?? 0
                }
                
                return try (0..<count).reduce(into: []) { (dates, i) in
                    do {
                        dates.append(
                            try decoder.decode(at: context.path[i], options: context.options) { pathDecoder in
                                try strategy.decode(from: pathDecoder)
                            }
                        )
                    } catch {
                        if context.options.contains(.lossy) == false {
                            throw error
                        }
                    }
                }
            }
        }
    }
}

import Foundation

public protocol BackedValue: Decodable {
    typealias Container = KeyedDecodingContainer<BackedCodingKey>
    static func decodeValue(using context: BackedDecodingContext) throws -> Self
}

public enum BackedError: Swift.Error {
    case invalidPath
    case missingValue
    case other(String)
}

extension Set: BackedValue where Element: Decodable {
    
    public static func decodeValue(using context: BackedDecodingContext) throws -> Self {
        do {
            return Set(try context.decode(Element.self) as [Element])
        } catch { }

        guard context.options.contains(.lossy) else {
            return try context.decode(Set<Element>.self)
        }

        var container = try context.unkeyedContainer()

        var elements: Set<Element> = []
        while !container.isAtEnd {
            if let value = try container.decode(Lossy<Element>.self).value {
                elements.insert(value)
            }
        }
        
        return elements
    }

}

extension Array: BackedValue where Element: Decodable {
    
    public static func decodeValue(using context: BackedDecodingContext) throws -> Self {
        do {
            return try context.decode(Element.self)
        } catch { }
        
        guard context.options.contains(.lossy) else {
            return try context.decode(Array<Element>.self)
        }

        var container = try context.unkeyedContainer()
        
        var elements: [Element] = []
        while !container.isAtEnd {
            if let value = try container.decode(Lossy<Element>.self).value {
                elements.append(value)
            }
        }
        
        return elements
    }

}

struct AnyDecodableValue: Codable {}

private struct Lossy<Value: Decodable>: Decodable {
    let value: Value?
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            value = try container.decode(Value.self)
        } catch {
            value = nil
        }
    }
}

private let iso8601DateFormatter = ISO8601DateFormatter()

extension Date: BackedValue {
    public static func decodeValue(using context: BackedDecodingContext) throws -> Self {
        switch context.dateDecodingStrategy {
        case .deferredToDate:
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
            ) ?? .missingValue
        case .formatted(let formatter):
            return try formatter.date(
                from: try context.decode(String.self)
            ) ?? .missingValue
        case .custom(let handler):
            return try handler(context.decoder)
        @unknown default:
            fatalError()
        }

    }
}

import Foundation

public struct PathDecoder {
    public let decoder: Decoder
    
    private func decode<T>(at path: Path, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy, options: BackedOptions, defaultValue: T?, decode: (BackedDecodingContext) throws -> T) throws -> T {
        do {
            let context = try BackedDecodingContext(
                decoder: decoder,
                path: path,
                options: options,
                dateDecodingStrategy: dateDecodingStrategy
            )
            return try decode(context)
        } catch {
            if let value = defaultValue {
                return value
            }
            throw error
        }
    }

    public func decode<T: BackedValue>(at path: Path, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, options: BackedOptions = [], defaultValue: T? = nil) throws -> T {
        try decode(at: path, dateDecodingStrategy: dateDecodingStrategy, options: options, defaultValue: defaultValue) {
            try T.decodeValue(using: $0)
        }
    }
    
    public func decode<T: Decodable>(at path: Path, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, options: BackedOptions = [], defaultValue: T? = nil) throws -> T {
        try decode(at: path, dateDecodingStrategy: dateDecodingStrategy, options: options, defaultValue: defaultValue) {
            try $0.decode()
        }
    }

}

@propertyWrapper
public final class Backed<T> {
        
    private(set) internal var decode: ((Decoder) throws -> T)!
    
    internal var _wrappedValue: T?
    
    internal var inferredPath: Path!

    public var wrappedValue: T {
        _wrappedValue!
    }

    public init(wrappedValue value: T) {
        _wrappedValue = value
        self.decode = { _ in value }
    }

    public init(_ value: T) {
        _wrappedValue = value
        self.decode = { _ in value }
    }
    
    public init(decoder pathDecoder: @escaping (PathDecoder, Path) throws -> T) {
        self.decode = { [unowned self] decoder in
            try pathDecoder(
                PathDecoder(decoder: decoder),
                self.inferredPath
            )
        }
    }

    public convenience init(decoder pathDecoder: @escaping (PathDecoder) throws -> T) {
        self.init { decoder, _ in
            try pathDecoder(decoder)
        }
    }

    public convenience init(_ path: Path? = nil, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, options: BackedOptions = [], defaultValue: T? = nil) where T : BackedValue {
        self.init { decoder, inferredPath in
            try decoder.decode(at: path ?? inferredPath, dateDecodingStrategy: dateDecodingStrategy, options: options, defaultValue: defaultValue)
        }
    }

    public convenience init(_ path: Path? = nil, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, options: BackedOptions = [], defaultValue: T? = nil) where T : Decodable {
        self.init { decoder, inferredPath in
            try decoder.decode(at: path ?? inferredPath, dateDecodingStrategy: dateDecodingStrategy, options: options, defaultValue: defaultValue)
        }
    }

    public var projectedValue: Backed<T> {
        self
    }
    
    internal func decodeWrappedValue(from decoder: Decoder) throws {
        _wrappedValue = try decode(decoder)
    }
}

extension Backed: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        _wrappedValue?.description ?? "nil"
    }
}

public struct BackedOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    
    public static let lossy = BackedOptions(rawValue: 1 << 0)
//    static let <#optionB#> = BackedOptions(rawValue: 1 << 1)
//    static let <#optionC#> = BackedOptions(rawValue: 1 << 2)
    
}


internal func ?? <T>(value: T?, error: BackedError) throws -> T {
    guard let value = value else {
        throw error
    }
    return value
}

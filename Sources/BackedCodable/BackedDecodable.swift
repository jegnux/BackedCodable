import Foundation

public protocol BackedDecodable: Decodable {
    init()
}

extension BackedDecodable {
    public init(from decoder: Decoder) throws {
        self = .init()
        for case (var key?, let value) in Mirror(reflecting: self).children {
            guard let backedType = value as? WrappedDecodable else {
                continue
            }
            if key.hasPrefix("_") {
                key.remove(at: key.startIndex)
            }
            backedType.inferredPath = Path(.key(key))
            try backedType.decodeWrappedValue(from: decoder)
        }
    }
}

extension Backed: WrappedDecodable {}
private protocol WrappedDecodable: AnyObject {
    var inferredPath: Path! { get set }
    func decodeWrappedValue(from decoder: Decoder) throws
}

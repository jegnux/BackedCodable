import Foundation
import BackedCodable
typealias Root = Path

import AppKit

struct Test2: Decodable {
    enum CodingKeys: String, CodingKey {
        case first_name
        case start_date
        case end_date
        case values
        case attributes
        case counts
    }
    
    struct Attributes {
        let values: [String]
    }
    
    let name: String
    let startDate: Date
    let endDate: Date
    let values: [String]
    let nestedValues: [String]
    let nestedInteger: Int
    let fruits: [String]
    let counts: [Int]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .first_name)
        self.startDate = Date(
            timeIntervalSince1970: try container.decode(Double.self, forKey: .start_date) / 1000
        )
        self.endDate = Date(
            timeIntervalSince1970: try container.decode(Double.self, forKey: .end_date)
        )
        
        struct Lossy<T: Decodable>: Decodable {
            let value: T?
            init(from decoder: Decoder) throws {
                value = try? decoder.singleValueContainer().decode(T.self)
            }
        }
        
        self.values = try container
            .decode([Lossy<String>].self, forKey: .values)
            .compactMap { $0.value }
        
        self.nestedValues = try container
            .nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            .decode([Lossy<String>].self, forKey: .values)
            .compactMap { $0.value }

        if let nestedInteger = try container
            .nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            .decode([Lossy<Int>].self, forKey: .values)[1].value {
            self.nestedInteger = nestedInteger
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: ""))
        }
        
        let counts = try container.decode([String: Int].self, forKey: .counts)
        
        self.fruits = Array(counts.keys)
        self.counts = Array(counts.values)
    }
}

struct Test: BackedDecodable {
    
    @Backed
    var test: Int
    
    @Backed(Root.first_name)
    var name: String
    
    @Backed(Root.start_date, dateDecodingStrategy: .millisecondsSince1970)
    var startDate: Date
    
    @Backed(Root.end_date, dateDecodingStrategy: .secondsSince1970)
    var endDate: Date
    
    @Backed(Root.values, options: .lossy, defaultValue: [])
    var values: [String]
    
    @Backed(Root.attributes.values, options: .lossy, defaultValue: [])
    var nestedValues: [String]
    
    @Backed(Root.attributes.values[1])
    var nestedInteger: Int
    
    @Backed(Root.counts[.allKeys])
    var fruits: [String]
    
    @Backed(Root.counts[.allValues])
    var counts: [Int]
    
    @Backed(Root.counts[.allKeys][0])
    var bestFruit: String
    
    @Backed(decoder: NSColor.decode(at: Root.foreground_color))
    var foregroundColor: NSColor

    @Backed(decoder: NSColor.decode(at: Root.background_color))
    var backgroundColor: NSColor
    
    @Backed(Path.counts[.keys(where: { (_: String, value: Int) in value < 10 })])
    var smallCountFruits: [String]
}

let json = """
{
    "test": 42,
    "first_name": "Steve",
    "start_date": 1613984296000,
    "end_date": 1613984996,
    "values": [12, "34", 56, "78"],
    "attributes": {
        "values": ["12", 34, "56", 78],
    },
    "foreground_color": {
        "hue": 255,
        "saturation": 128,
        "brightness": 128
    },
    "background_color": {
        "red": 255,
        "green": 128,
        "blue": 128
    },
    "counts": {
        "apples": 12,
        "oranges": 9,
        "bananas": 6
    }
}
"""

let result = try JSONDecoder().decode(Test.self, from: Data(json.utf8))
print("Test(")
print(
    Mirror(reflecting: result).children
        .map { key, value in "\t\(key!): \(value)" }
        .joined(separator: ",\n")
)
print(")")

extension NSColor {
    static func decode(at path: Path) -> (_ decoder: PathDecoder) throws -> NSColor {
        { decoder in
            do {
                return try decodeFromHSBA(at: path)(decoder)
            } catch {
                return try decodeFromRGBA(at: path)(decoder)
            }
        }
    }
    
    static func decodeFromHSBA(at path: Path) -> (_ decoder: PathDecoder) throws -> NSColor {
        { decoder in
            NSColor(
                hue: try decoder.decode(at: path.hue) / 255.0,
                saturation: try decoder.decode(at: path.saturation) / 255.0,
                brightness: try decoder.decode(at: path.brightness) / 255.0,
                alpha: (try? decoder.decode(at: path.alpha) / 255.0) ?? 1
            )
        }
    }

    static func decodeFromRGBA(at path: Path) -> (_ decoder: PathDecoder) throws -> NSColor {
        { decoder in
            NSColor(
                red: try decoder.decode(at: path.red) / 255.0,
                green: try decoder.decode(at: path.green) / 255.0,
                blue: try decoder.decode(at: path.blue) / 255.0,
                alpha: (try? decoder.decode(at: path.alpha) / 255.0) ?? 1
            )
        }
    }
}

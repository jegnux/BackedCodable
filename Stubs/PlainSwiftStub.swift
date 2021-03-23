//
//  PlainSwiftStub.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct PlainSwiftStub: Decodable {
    public enum CodingKeys: String, CodingKey {
        case someString
        case someArray
        case someDate
        case first_name
        case start_date
        case end_date
        case values
        case attributes
        case counts
    }

    public struct Attributes {
        public let values: [String]
    }

    public let someString: String?
    public let someArray: [String]?
    public let someDate: Date?
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let values: [String]
    public let nestedValues: [String]
    public let nestedInteger: Int
    public let fruits: [String]
    public let counts: [Int]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.someString = try? container.decode(String?.self, forKey: .someString)
        self.someArray = try? container.decode([String]?.self, forKey: .someArray)
        self.someDate = try? container.decode(Date?.self, forKey: .someDate)

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
                self.value = try? decoder.singleValueContainer().decode(T.self)
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
            .decode([Lossy<Int>].self, forKey: .values)[1].value
        {
            self.nestedInteger = nestedInteger
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: ""))
        }

        let counts = try container.decode([String: Int].self, forKey: .counts)

        self.fruits = Array(counts.keys)
        self.counts = Array(counts.values)
    }
}

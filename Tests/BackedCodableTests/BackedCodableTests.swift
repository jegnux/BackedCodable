//
//  BackedCodableTests.swift
//
//  Created by Jérôme Alves.
//

import BackedCodable
import XCTest

struct SUT: BackedDecodable, Equatable {
    init() {}

    init(
        name: String,
        startDate: Date,
        endDate: Date,
        values: [String],
        nestedValues: [String],
        nestedInteger: Int,
        fruits: [Fruits],
        counts: [Int],
        bestFruit: String,
        lastCount: Int,
        smallCountFruits: [String],
        firstSmallCountFruit: String
    ) {
        self._name = Backed(name)
        self._startDate = Backed(startDate)
        self._endDate = Backed(endDate)
        self._values = Backed(values)
        self._nestedValues = Backed(nestedValues)
        self._nestedInteger = Backed(nestedInteger)
        self._fruits = Backed(fruits)
        self._counts = Backed(counts)
        self._bestFruit = Backed(bestFruit)
        self._lastCount = Backed.init(lastCount)
        self._smallCountFruits = Backed(smallCountFruits)
        self._firstSmallCountFruit = Backed(firstSmallCountFruit)
    }

    @Backed()
    var someString: String?

    @Backed()
    var someArray: [String]?

    @Backed()
    var someDate: Date?

    @Backed(strategy: .secondsSince1970)
    var someDateSince1970: Date?

    @Backed(Path.full_name ?? Path.name ?? Path.first_name)
    var name: String

    @Backed(Path.start_date, strategy: .deferredToDecoder)
    var startDate: Date

    @Backed(Path.end_date, strategy: .secondsSince1970)
    var endDate: Date

    @Backed(Path.values, defaultValue: [], options: .lossy)
    var values: [String]

    @Backed(Path.attributes.values, options: .lossy)
    var nestedValues: [String]?

    @Backed(Path.attributes.values[1])
    var nestedInteger: Int

    @Backed(Path.counts[.allKeys], options: .lossy)
    var fruits: [Fruits]

    @Backed(Path.counts[.allValues])
    var counts: [Int]

    @Backed(Path.counts[.allKeys][0])
    var bestFruit: String

    @Backed(Path.counts[.allValues][2])
    var lastCount: Int

    @Backed(Path.counts[.keys(where: hasSmallCount)])
    var smallCountFruits: [String]

    @Backed(Path.counts[.keys(where: hasSmallCount)][0])
    var firstSmallCountFruit: String
}

private func hasSmallCount(_: String, value: Int) -> Bool {
    value < 10
}

enum Fruits: String, Decodable {
    case apples, bananas
}

let json = """
{
    "name": "Steve",
    "start_date": 1613984296000,
    "end_date": 1613984996,
    "values": [12, "34", 56, "78"],
    "attributes": {
        "values": ["12", 34, "56", 78],
    },
    "counts": {
        "apples": 12,
        "oranges": 9,
        "bananas": 6
    }
}
"""

final class BackedCodableTests: XCTestCase {
    func testDecode() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        let sut = try decoder.decode(SUT.self, from: Data(json.utf8))

        XCTAssertEqual(
            sut,
            SUT(
                name: "Steve",
                startDate: Date(timeIntervalSince1970: 1_613_984_296),
                endDate: Date(timeIntervalSince1970: 1_613_984_996),
                values: ["34", "78"],
                nestedValues: ["12", "56"],
                nestedInteger: 34,
                fruits: [.apples, .bananas],
                counts: [12, 6, 9],
                bestFruit: "apples",
                lastCount: 9,
                smallCountFruits: ["bananas", "oranges"],
                firstSmallCountFruit: "bananas"
            )
        )
    }

    static var allTests = [
        ("testExample", testDecode),
    ]
}

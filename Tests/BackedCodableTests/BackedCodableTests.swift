import XCTest
import BackedCodable

struct SUT: BackedDecodable, Equatable {
    
    init() {}
    
    init(
        name: String,
        startDate: Date,
        endDate: Date,
        values: [String],
        nestedValues: [String],
        nestedInteger: Int,
        fruits: [String],
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
        self._lastCount = Backed(lastCount)
        self._smallCountFruits = Backed(smallCountFruits)
        self._firstSmallCountFruit = Backed(firstSmallCountFruit)
    }
    
    @Backed(Path.first_name)
    var name: String
    
    @Backed(Path.start_date, dateDecodingStrategy: .millisecondsSince1970)
    var startDate: Date

    @Backed(Path.end_date, dateDecodingStrategy: .secondsSince1970)
    var endDate: Date

    @Backed(Path.values, options: .lossy, defaultValue: [])
    var values: [String]

    @Backed(Path.attributes.values, options: .lossy, defaultValue: [])
    var nestedValues: [String]

    @Backed(Path.attributes.values[1])
    var nestedInteger: Int

    @Backed(Path.counts[.allKeys])
    var fruits: [String]

    @Backed(Path.counts[.allValues])
    var counts: [Int]
    
    @Backed(Path.counts[~][0])
    var bestFruit: String

    @Backed(Path.counts[*][2])
    var lastCount: Int
    
    @Backed(Path.counts[.keys(where: hasSmallCount)])
    var smallCountFruits: [String]

    @Backed(Path.counts[.keys(where: hasSmallCount)][0])
    var firstSmallCountFruit: String
}

private func hasSmallCount(_: String, value: Int) -> Bool {
    value < 10
}

let json = """
    {
        "first_name": "Steve",
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
        let sut = try JSONDecoder().decode(SUT.self, from: Data(json.utf8))
        
        XCTAssertEqual(
            sut,
            SUT(
                name: "Steve",
                startDate: Date(timeIntervalSince1970: 1613984296),
                endDate: Date(timeIntervalSince1970: 1613984996),
                values: ["34", "78"],
                nestedValues: ["12", "56"],
                nestedInteger: 34,
                fruits: ["apples", "bananas", "oranges"],
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

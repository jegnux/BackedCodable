//
//  BackedCodableTests.swift
//
//  Created by Jérôme Alves.
//

import XCTest
@testable import BackedCodable
@testable import BackedCodableStubs

final class BackedCodableTests: XCTestCase {
    func testDecode() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970

        let sut = try decoder.decode(BackedStub.self, from: jsonStub)

        XCTAssertEqual(
            sut,
            BackedStub(
                name: "Steve",
                startDate: Date(timeIntervalSince1970: 1_613_984_296),
                endDate: Date(timeIntervalSince1970: 1_613_984_996),
                dates: [
                    Date(timeIntervalSince1970: 1_613_984_296),
                    Date(timeIntervalSince1970: 1_613_984_996),
                ],
                values: ["34", "78"],
                nestedValues: ["12", "56"],
                nestedInteger: 34,
                fruits: [.apples, .bananas],
                counts: [12, 6, 9],
                bestFruit: "apples",
                lastCount: 9,
                smallCountFruits: ["bananas", "oranges"],
                firstSmallCountFruit: "bananas",
                foregroundColor: Color.hsba(hue: 255 / 255, saturation: 128 / 255, brightness: 128 / 255, alpha: 1),
                backgroundColor: Color.rgba(red: 255 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1),
                birthdays: [
                    Date(timeIntervalSince1970: -468691200),
                    Date(timeIntervalSince1970: -289238400),
                ],
                timCookBirthday: Date(timeIntervalSince1970: -289238400)
            )
        )
    }
    
    func testPath() throws {
        XCTAssertEqualComponents(
            Path(),
            [[]]
        )
        XCTAssertEqualComponents(
            Path.foo,
            [[.key("foo")]]
        )
        XCTAssertEqualComponents(
            Path.foo ?? Path.bar,
            [[.key("foo")], [.key("bar")]]
        )
        XCTAssertEqualComponents(
            Path.foo ?? Path.bar ?? Path.test,
            [[.key("foo")], [.key("bar")], [.key("test")]]
        )
        XCTAssertEqualComponents(
            (Path.foo ?? Path.bar ?? Path.test).wow,
            [[.key("foo"), .key("wow")], [.key("bar"), .key("wow")], [.key("test"), .key("wow")]]
        )
    }

    static var allTests = [
        ("testExample", testDecode),
        ("testPath", testPath)
    ]
}

private func XCTAssertEqualComponents(_ path: Path, _ components: [[PathComponent]], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(path.components, components, file: file, line: line)
}

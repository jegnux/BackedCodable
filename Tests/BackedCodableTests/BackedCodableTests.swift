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

        typealias SUT = BackedStub
        let sut = try decoder.decode(SUT.self, from: jsonStub)

        XCTAssertEqual(
            sut,
            SUT(
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
                    Date(timeIntervalSince1970: -468_691_200),
                    Date(timeIntervalSince1970: -289_238_400),
                ],
                timCookBirthday: Date(timeIntervalSince1970: -289_238_400)
            )
        )
    }

    func testPath() throws {
        XCTAssertEqual("test", PathComponent.key("test"))
        XCTAssertEqual(1337, PathComponent.index(1337))

        let testString = "test"
        let testInt = 1337

        XCTAssertEqual(testString.makePathComponent(), PathComponent.key("test"))
        XCTAssertEqual(testInt.makePathComponent(), PathComponent.index(1337))

        XCTAssertEqualComponents(
            Path.root,
            [[]]
        )
        XCTAssertEqualComponents(
            Path("foo"),
            [[.key("foo")]]
        )
        XCTAssertEqualComponents(
            "foo" ?? "bar",
            [[.key("foo")], [.key("bar")]]
        )
        XCTAssertEqualComponents(
            "foo" ?? "bar" ?? "test",
            [[.key("foo")], [.key("bar")], [.key("test")]]
        )
        XCTAssertEqualComponents(
            ("foo" ?? "bar" ?? "test").appending("wow", 42),
            [
                [.key("foo"), .key("wow"), .index(42)],
                [.key("bar"), .key("wow"), .index(42)],
                [.key("test"), .key("wow"), .index(42)],
            ]
        )
        XCTAssertEqualComponents(
            "",
            [[]]
        )
        XCTAssertEqualComponents(
            "foo",
            [["foo"]]
        )
        XCTAssertEqualComponents(
            "foo.bar",
            [["foo.bar"]]
        )
    }

    static var allTests = [
        ("testExample", testDecode),
        ("testPath", testPath),
    ]
}

private func XCTAssertEqualComponents(_ path: Path, _ components: [[PathComponent]], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(path.components, components, file: file, line: line)
}

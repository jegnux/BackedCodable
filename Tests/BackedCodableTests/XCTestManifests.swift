//
//  XCTestManifests.swift
//
//  Created by Jérôme Alves.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BackedCodableTests.allTests),
    ]
}
#endif

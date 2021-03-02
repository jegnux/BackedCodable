//
//  LinuxMain.swift
//
//  Created by Jérôme Alves.
//

import XCTest

import BackedCodableTests

var tests = [XCTestCaseEntry]()
tests += BackedCodableTests.allTests()
XCTMain(tests)

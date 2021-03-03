//
//  BackedError.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct BackedError: Swift.Error, CustomStringConvertible {
    let errorDescription: String
    let file: StaticString
    let line: UInt
//    let callStackSymbols: [String] = Thread.callStackSymbols

    static func invalidPath(_ path: Path? = nil, file: StaticString = #fileID, line: UInt = #line) -> BackedError {
        if let path = path {
            return BackedError(errorDescription: "Invalid Path: \(path)", file: file, line: line)
        } else {
            return BackedError(errorDescription: "Invalid Path", file: file, line: line)
        }
    }

    static func missingValue(file: StaticString = #fileID, line: UInt = #line) -> BackedError {
        BackedError(errorDescription: "Missing Value", file: file, line: line)
    }

    static func other(_ errorDescription: String, file: StaticString = #fileID, line: UInt = #line) -> BackedError {
        BackedError(errorDescription: errorDescription, file: file, line: line)
    }

    public var description: String {
        let strings = [
            errorDescription,
            "\(file):\(line)",
        ]
//        + callStackSymbols.map { "\t\($0)" }
        return strings.joined(separator: "\n")
    }
}

internal func ?? <T>(value: T?, error: BackedError) throws -> T {
    guard let value = value else {
        throw error
    }
    return value
}

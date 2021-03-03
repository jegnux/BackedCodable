//
//  Contents.swift
//
//  Created by Jérôme Alves.
//

import BackedCodableStubs
import Foundation

func prettyPrint(_ values: Any...) {
    for value in values {
        print("\(type(of: value))(")
        print(
            Mirror(reflecting: value).children
                .map { key, value in "  \(key!): \(value)" }
                .joined(separator: ",\n")
        )
        print(")")
    }
}

let backedStub = try JSONDecoder().decode(BackedStub.self, from: jsonStub)
let plainSwiftStub = try JSONDecoder().decode(PlainSwiftStub.self, from: jsonStub)

prettyPrint(backedStub, plainSwiftStub)

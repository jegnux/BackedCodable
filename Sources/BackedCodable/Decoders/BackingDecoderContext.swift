//
//  BackingDecoderContext.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct BackingDecoderContext {
    public let givenPath: Path?
    public let inferredPath: Path?
    public let options: BackingDecoderOptions

    public var path: Path {
        switch (givenPath, inferredPath) {
        case (let given?, let inferred?):
            return given ?? inferred
        case (let given, let inferred):
            return given ?? inferred ?? Path()
        }
    }

    internal init(givenPath: Path?, inferredPath: Path? = nil, options: BackingDecoderOptions) {
        self.givenPath = givenPath
        self.inferredPath = inferredPath
        self.options = options
    }

    func withInferredPath(_ path: Path) -> BackingDecoderContext {
        BackingDecoderContext(givenPath: givenPath, inferredPath: path, options: options)
    }
}

public struct BackingDecoderOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int
    public static let lossy = BackingDecoderOptions(rawValue: 1 << 0)
}

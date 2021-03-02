//
//  BackingDecoderContext.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public struct BackingDecoderContext {
    public let path: Path
    public let options: BackingDecoderOptions

    func withInferredPath(_ path: Path) -> BackingDecoderContext {
        BackingDecoderContext(path: self.path ?? path, options: options)
    }
}

public struct BackingDecoderOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int
    public static let lossy = BackingDecoderOptions(rawValue: 1 << 0)
}

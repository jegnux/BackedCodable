//
//  PathStorage.swift
//
//  Created by Jérôme Alves.
//

import Foundation

internal indirect enum PathStorage: Hashable {
    case root
    case or(PathStorage, PathStorage)
    case child(PathStorage, PathComponent)

    var components: [[PathComponent]] {
        var buffer: [PathStorage] = [self]
        var components: [[PathComponent]] = []

        while let path = buffer.popLast() {
            switch path {
            case .root:
                continue
            case .or(let lhs, let rhs):
                components += lhs.components
                components += rhs.components
            case .child(let path, let component):
                var last = components.popLast() ?? []
                last.insert(component, at: last.startIndex)
                components.append(last)
                buffer.append(path)
            }
        }

        return components
    }

    mutating func append(_ pathComponent: PathComponent) {
        self = appending(pathComponent)
    }

    func appending(_ pathComponent: PathComponent) -> PathStorage {
        switch self {
        case .or(let lhs, let rhs):
            return .or(lhs.appending(pathComponent), rhs.appending(pathComponent))
        default:
            return .child(self, pathComponent)
        }
    }
}

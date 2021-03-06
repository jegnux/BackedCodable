//
//  Helpers.swift
//
//  Created by Jérôme Alves.
//

import Foundation

public enum Color: Equatable {
    case rgba(red: Float, green: Float, blue: Float, alpha: Float)
    case hsba(hue: Float, saturation: Float, brightness: Float, alpha: Float)
}

public enum Fruits: String, Decodable, Equatable {
    case apples, bananas
}

public func hasSmallCount(_: String, value: Int) -> Bool {
    value < 10
}

public var jsonStub: Data {
    let json = """
    {
        "name": "Steve",
        "dates": [1613984296, "N/A", 1613984996],
        "values": [12, "34", 56, "78"],
        "attributes": {
            "values": ["12", 34, "56", 78],
            "all dates": {
                "start_date": 1613984296000,
                "end_date": 1613984996
            }
        },
        "counts": {
            "apples": 12,
            "oranges": 9,
            "bananas": 6
        },
        "foreground_color": {
            "hue": 255,
            "saturation": 128,
            "brightness": 128
        },
        "background_color": {
            "red": 255,
            "green": 128,
            "blue": 128
        },
        "birthdays": {
            "Steve Jobs": -468691200,
            "Tim Cook": -289238400
        }
    }
    """
    return Data(json.utf8)
}

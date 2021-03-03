//
//  BackedStub.swift
//
//  Created by Jérôme Alves.
//

import BackedCodable
import Foundation

public struct BackedStub: BackedDecodable, Equatable {
    public init() {}

    public init(
        name: String,
        startDate: Date,
        endDate: Date,
        values: [String],
        nestedValues: [String],
        nestedInteger: Int,
        fruits: [Fruits],
        counts: [Int],
        bestFruit: String,
        lastCount: Int,
        smallCountFruits: [String],
        firstSmallCountFruit: String,
        foregroundColor: Color,
        backgroundColor: Color
    ) {
        self._name = Backed(name)
        self._startDate = Backed(startDate)
        self._endDate = Backed(endDate)
        self._values = Backed(values)
        self._nestedValues = Backed(nestedValues)
        self._nestedInteger = Backed(nestedInteger)
        self._fruits = Backed(fruits)
        self._counts = Backed(counts)
        self._bestFruit = Backed(bestFruit)
        self._lastCount = Backed.init(lastCount)
        self._smallCountFruits = Backed(smallCountFruits)
        self._firstSmallCountFruit = Backed(firstSmallCountFruit)
        self._foregroundColor = Backed(foregroundColor)
        self._backgroundColor = Backed(backgroundColor)
    }

    @Backed()
    public var someString: String?

    @Backed()
    public var someArray: [String]?

    @Backed()
    public var someDate: Date?

    @Backed(strategy: .secondsSince1970)
    public var someDateSince1970: Date?

    @Backed(Path.full_name ?? Path.name ?? Path.first_name)
    public var name: String

    @Backed(Path.start_date, strategy: .deferredToDecoder)
    public var startDate: Date

    @Backed(Path.end_date, strategy: .secondsSince1970)
    public var endDate: Date

    @Backed(Path.values, defaultValue: [], options: .lossy)
    public var values: [String]

    @Backed(Path.attributes.values, options: .lossy)
    public var nestedValues: [String]?

    @Backed(Path.attributes.values[1])
    public var nestedInteger: Int

    @Backed(Path.counts[.allKeys], options: .lossy)
    public var fruits: [Fruits]

    @Backed(Path.counts[.allValues])
    public var counts: [Int]

    @Backed(Path.counts[.allKeys][0])
    public var bestFruit: String

    @Backed(Path.counts[.allValues][2])
    public var lastCount: Int

    @Backed(Path.counts[.keys(where: hasSmallCount)])
    public var smallCountFruits: [String]

    @Backed(Path.counts[.keys(where: hasSmallCount)][0])
    public var firstSmallCountFruit: String

    @Backed(Path.foreground_color, decoder: .HSBAColor)
    public var foregroundColor: Color

    @Backed(Path.background_color, decoder: .RGBAColor)
    public var backgroundColor: Color
}

extension BackingDecoder where Value == Color {
    public static var HSBAColor: BackingDecoder<Color> {
        BackingDecoder<Color> { decoder, context in
            Color.hsba(
                hue: try decoder.decode(at: context.path.hue) / 255.0,
                saturation: try decoder.decode(at: context.path.saturation) / 255.0,
                brightness: try decoder.decode(at: context.path.brightness) / 255.0,
                alpha: (try? decoder.decode(at: context.path.alpha) / 255.0) ?? 1
            )
        }
    }

    public static var RGBAColor: BackingDecoder<Color> {
        BackingDecoder<Color> { decoder, context in
            Color.rgba(
                red: try decoder.decode(at: context.path.red) / 255.0,
                green: try decoder.decode(at: context.path.green) / 255.0,
                blue: try decoder.decode(at: context.path.blue) / 255.0,
                alpha: (try? decoder.decode(at: context.path.alpha) / 255.0) ?? 1
            )
        }
    }
}

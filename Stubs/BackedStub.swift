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
        dates: [Date],
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
        backgroundColor: Color,
        birthdays: [Date],
        timCookBirthday: Date
    ) {
        self.$name = name
        self.$startDate = startDate
        self.$endDate = endDate
        self.$dates = dates
        self.$values = values
        self.$nestedValues = nestedValues
        self.$nestedInteger = nestedInteger
        self.$fruits = fruits
        self.$counts = counts
        self.$bestFruit = bestFruit
        self.$lastCount = lastCount
        self.$smallCountFruits = smallCountFruits
        self.$firstSmallCountFruit = firstSmallCountFruit
        self.$foregroundColor = foregroundColor
        self.$backgroundColor = backgroundColor
        self.$birthdays = birthdays
        self.$timCookBirthday = timCookBirthday
    }

    @Backed()
    public var someString: String?

    @Backed()
    public var someArray: [String]?

    @Backed()
    public var someDate: Date?

    @Backed(strategy: .secondsSince1970)
    public var someDateSince1970: Date?

    @Backed("full_name" ?? "name" ?? "first_name")
    public var name: String

    @Backed(Path("attributes", "all dates", "start_date"), strategy: .deferredToDecoder)
    public var startDate: Date

    @Backed(Path("attributes", "all dates", "end_date"), strategy: .secondsSince1970)
    public var endDate: Date

    @Backed("dates", options: .lossy, strategy: .secondsSince1970)
    public var dates: [Date]

    @Backed("values", defaultValue: [], options: .lossy)
    public var values: [String]

    @Backed(Path("attributes", "values"), options: .lossy)
    public var nestedValues: [String]?

    @Backed(Path("attributes", "values", 1))
    public var nestedInteger: Int

    @Backed(Path("counts", .allKeys), options: .lossy)
    public var fruits: [Fruits]

    @Backed(Path("counts", .allValues))
    public var counts: [Int]

    @Backed(Path("counts", .allKeys, 0))
    public var bestFruit: String

    @Backed(Path("counts", .allValues, 2))
    public var lastCount: Int

    @Backed(Path("counts", .keys(where: hasSmallCount)))
    public var smallCountFruits: [String]

    @Backed(Path("counts", .keys(where: hasSmallCount), 0))
    public var firstSmallCountFruit: String

    @Backed("foreground_color", decoder: .HSBAColor)
    public var foregroundColor: Color

    @Backed("background_color", decoder: .RGBAColor)
    public var backgroundColor: Color

    @Backed(Path("birthdays", .allValues), strategy: .secondsSince1970)
    public var birthdays: [Date]

    @Backed(Path("birthdays", .allValues, 1), strategy: .secondsSince1970)
    public var timCookBirthday: Date
}

extension BackingDecoder where Value == Color {
    public static var HSBAColor: BackingDecoder<Color> {
        BackingDecoder<Color> { decoder, context in
            Color.hsba(
                hue: try decoder.decode(at: context.path.appending("hue")) / 255.0,
                saturation: try decoder.decode(at: context.path.appending("saturation")) / 255.0,
                brightness: try decoder.decode(at: context.path.appending("brightness")) / 255.0,
                alpha: (try? decoder.decode(at: context.path.appending("alpha")) / 255.0) ?? 1
            )
        }
    }

    public static var RGBAColor: BackingDecoder<Color> {
        BackingDecoder<Color> { decoder, context in
            Color.rgba(
                red: try decoder.decode(at: context.path.appending("red")) / 255.0,
                green: try decoder.decode(at: context.path.appending("green")) / 255.0,
                blue: try decoder.decode(at: context.path.appending("blue")) / 255.0,
                alpha: (try? decoder.decode(at: context.path.appending("alpha")) / 255.0) ?? 1
            )
        }
    }
}

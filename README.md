# BackedCodable
Powerful property wrapper to back codable properties.

## Why

Swift's Codable is a great language feature but easily becomes verbose and requires a lot of boilerplate as soon as your serialized files (JSON, Plist) differ from the model you actually want for your app.

**BackedCodable** offers a **single** property wrapper to annotate your properties in a declarative way, instead of the good old imperative `init(from:Decoder)`.

[Other](https://github.com/marksands/BetterCodable) [libraries](https://github.com/GottaGetSwifty/CodableWrappers) solve Decodable issues using property wrappers as well, but IMO they are limitied by the fact you can apply only one property wrapper per property. So for example, you have to choose between `@LossyArray` and `@DefaultEmptyArray`.  

With this library, you'll be able to write things like `@Backed(Path("attributes", "dates"), options: .lossy, strategy: .secondsSince1970)` to decode a *lossy* array of dates using a *seconds since 1970* strategy at the key `dates` of the nested dictionary `attributes`.

## Installation

**BackedDecodable** is installable using the Swift Package Manager.

## Usage

- Mark **all** properties of your model with `@Backed()`
- Make your model conform to `BackedDecodable` ; it just requires a `init()`

## Features

A single `@Backed` property wrapper provides you all the following features.

Custom decoding path: 
```swift 
@Backed() // key is inferred from property name: "firstName"
var firstName: String 

@Backed("first_name") // custom key 
var firstName: String

@Backed(Path("attributes", "first_name")) // key "first_name" nested in "attributes" dictionary 
var firstName: String

@Backed(Path("attributes", "first_name") ?? "first_name")  // will try "attributes.first_name" and if it fails "first_name" 
var firstName: String
```
A `Path` is composed of different `PathComponent`:
- `.key(String)`: also expressible by a String literal (`Path("foo") == Path(.key("foo"))`)
- `.index(Int)`: also expressible by an Integer literal (`Path("foo", 0) == Path(.key("foo"), .index(0))`)
- `.allKeys`: get all keys from a dictionary
- `.allValues`: get all values from a dictionary
- `.keys(where: { key, value -> Bool })`: filter elements of a dictionary and extract their keys
- `.values(where: { key, value -> Bool })`: filter elements of a dictionary and extract their values

Lossy collections filter out invalid or null items and keep only what success. It's a kind of `.compactMap()`.
```swift
@Backed(options: .lossy) 
var items: [Item]

@Backed(options: .lossy) 
var tags: Set<String>
```

Default values for when a key is missing, value is `null` of value isn't in the right format: 
```swift
@Backed(defaultValue: .unknown) 
var itemType: ItemType

`@Backed() // defaultValue is automatically set to `nil` so decoding an optional never "fails" 
var name: String? 
```

Custom date decoding strategy per property: 
```swift
@Backed("start_date", strategy: .secondsFrom1970) 
var startDate: Date

@Backed("end_date", strategy: .millisecondsFrom1970) 
var endDate: Date
```


Custom decoder for when a single decoding strategy doesn't stand out: 
```swift
@Backed("foreground_color", decoder: .HSBAColor) 
var foregroundColor: UIColor

@Backed("background_color", decoder: .RGBAColor) 
var backgroundColor: UIColor
```

Extensions on `Decoder` to benefit some of the features above:
```swift
init(from decoder: Decoder) throws {
    self.id = try decoder.decoder(String.self, at: "uuid")`
    self.title = try decoder.decoder(String.self, at: Path("attributes", "title"))`
    self.tags = try decoder.decoder([String].self, at: Path("attributes", "tags"), options: .lossy)`
}
```

## Example

Given the following JSON:
```json
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
```

All of this is possible:
```swift
public struct BackedStub: BackedDecodable, Equatable {
    public init() {}

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
```

## FAQ

#### How do I declare a memberwise initizializer?
```swift
struct User: BackedDecodable {
    init() {} // required by BackedDecodable
    
    init(id: String, firstName: String, lastName: String) {
        self.$id = id
        self.$firstName = firstName
        self.$lastName = lastName
    }
    
    @Backed("uuid")
    var id: String

    @Backed(Path("attributes", "first_name"))
    var firstName: String
    
    @Backed(Path("attributes", "last_name"))
    var lastName: String
}
```
#### What happen if I init my model with the required `.init()`?
Unfortunately, if you let the init body empty, it will crash. 
To avoid the crash, must be sure to set all `self.$property`  in the init like in the memberwise init.
This is a known limitation for which I didn't find any solution.

#### Do I need to have all my model backed by **BackedDecodable**?
No! Backed model works on their own and can be composed of plain Decodable properties.


## To-do
- [ ] support Encodable
- [ ] support mutable properties
- [ ] Data strategies

## Thanks

- Thanks to the many [reads](https://www.swiftbysundell.com/articles/property-wrappers-in-swift/) and [libraries](https://github.com/GottaGetSwifty/CodableWrappers) that inspired this project.
- Thanks to [JSON API](https://jsonapi.org) for this great JSON format full of nested payloads...

## Author

[Jérôme Alves](https://twitter.com/jegnux)

## License

**BackedCodable** is available under the MIT license. See the [LICENSE](LICENSE) file for more info.


# ⌚️ Time [![Build Status](https://travis-ci.org/OhItsShaun/Time.svg?branch=master)](https://travis-ci.org/OhItsShaun/Time)

A Swift package to represent time by hour and minute with an API to retrieve the time of astronomical phases (such as sunset and sunrise) from 3rd party service. 

## Simple Time  
A value of `Time` represents time by its hour and minute, `Time(hour: 13, minute: 30)`.

`Time` supports basic arithmetic operations:

````Swift 
var time = Time(hour: 13, minute: 30)
let laterTime = time + Time(hour: 0, minute: 5) 	// 13:35
let earlierTime = time - Time(hour: 0, minute: 5) 	// 13:25
````

## Astronomic Time
An API for determining the time of sunset and sunrise at a location is provided. To retrieve the sunset for today:

````Swift
let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513") // provide your own location
let sunset = Time.Astronomic(of: .sunset, at: location)
````

`Time.Astronomic` conforms to `TimeRepresentable` and utilises the lazy-like evaluation. `Time.Astronomic(of:at:)` will dispatch a block to asynchronously determine the sunset and sunrise of a location whilst your code continues executing. If the properties of `Time.Astronomic` are accessed before the background task has finished, execution of the thread will pause until the time is determined or timeout after a few seconds. Timeout will return a fallback value of each astronomical phase. 

`Time.Astronomic` caches the times retrieved of sunset and sunrise.

If `.today`, `.yesterday` or `.tomorrow` is supplied as an argument when initialising `Time.Offset`, the time of sunset and sunrise will be determined for the day of runtime execution, i.e. if `sunset.minute` was called on the 23rd Nov it will return the sunset for the 23rd of Nov even if the value was instanced on the 20th Nov and the argument provided was `.today`.


## Offset Time 
`TimeRepresentable` can be offset. For example, to retrieve sunset minus 45 minutes:

````Swift 
let earlierSunset = Time.Offset(sunset, minus: Time(hour: 0, minute: 45))
````

## Time Representable
More complex and dynamic constructs of time can be made from conforming to the `TimeRepresentable` protocol. When a value of time is created from a `TimeRepresentable`, `Time` will act "lazily" and only evalute the properties defined in `TimeRepresentable` when the type `Time` itself is evaluated. This enables conformants of `TimeRepresentable` to perform background tasks or change dynamically whilst still contained in the same value of time.

Due to limitations with Swifts generics only `Time` conform to `Equatable` and `Comparable`; the `TimeRepresentable` protocol does not. Wrapping `TimeRepresentable` conformants as `Time` values enables comparability without losing the dynamic behaviour of `TimeRepresentable`. For example:

````Swift 
let time1 = Time(from: sunrise)
let time2 = Time(from: earlierSunset)

// time1 != time2
````

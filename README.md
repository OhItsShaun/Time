# ⌚️ Time [![Build Status](https://travis-ci.org/OhItsShaun/Time.svg?branch=master)](https://travis-ci.org/OhItsShaun/Time)

A Swift package to represent time by hour and minute, with an API to retrieve the time of astronomical phases (such as sunset and sunrise) from 3rd party service.

## Simple Time  

A value of `Time` represents time by only hours and minutes, `Time(hour: 13, minute: 30)`.

`Time` supports basic arithmetic operations:

````Swift 
var time = Time(hour: 13, minute: 30)
let laterTime = time + Time(hour: 0, minute: 5) 	// 13:35
let earlierTime = time - Time(hour: 0, minute: 5) 	// 13:25
````

## Time Generators
More complex and dynamic constructs of time can be made from conforming to the `TimeGenerator` protocol. When a value of time is created from a `TimeGenerator`, `Time` will act "lazily" and only evalute the properties defined in `TimeGenerator` when the type `Time` itself is evaluated. This enables conformants of `TimeGenerator` to perform background tasks or change dynamically whilst still contained in the same value of time.

## Astronomical Phases
`AstronomicalTime` conforms to `TimeGenerator` and utilises the lazy-like evaluation, allowing astronomical phases such as sunrise and sunset to be loaded in the background whilst the program continues execution.

````Swift
let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
let sunset = AstronomicalTime(of: .sunset, at: location)
time = Time(from: sunset) // time will now be when sunset in `location` occurs
````

Here `sunet` and `time` will return from the initialiser whilst the hour and minute of sunset are calculated in the background. If `time.hour` or `time.minute` is accessed before the background task has finished, `time` will wait for the background task to finish or timeout after a few seconds. Timeout will return a fallback value of each astronomical phase. 

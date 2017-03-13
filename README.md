A Swift package to represent time by hour and minute, with an API to retrieve the time of astronomical phases (such as sunset and sunrise) from 3rd party service.

## Usage 
````Swift 
var time = Time(hour: 13, minute: 3)     // 13:30
let laterTime = time + Time(hour: 0, minute: 5) 

let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
let sunset = AstronomicalTime(of: .sunset, at: location, for: "2017-02-15")
time = Time(from: sunset)
````
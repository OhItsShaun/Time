import XCTest
@testable import Time

class TimeTests: XCTestCase {
    
    
    func testStaticTime() {
        let time = Time(hour: 10, minute: 3)
        XCTAssert(time.hour == 10 && time.minute == 3)
    }
    
    func testEquality() {
        let time1 = Time(hour: 10, minute: 3)
        let time2 = Time(hour: 10, minute: 3)
        let time3 = Time(hour: 14, minute: 6)
        
        XCTAssert(time1 == time2)
        XCTAssert(time1 != time3)
    }
    
    func testComparable() {
        let time1 = Time(hour: 10, minute: 00)
        let time2 = Time(hour: 10, minute: 03)
        let time3 = Time(hour: 10, minute: 03)
        let time4 = Time(hour: 15, minute: 40)
        
        XCTAssert(time1 < time2)
        XCTAssert(time1 <= time2)
        XCTAssert(!(time1 > time2))
        XCTAssert(!(time1 >= time2))
        
        XCTAssert(!(time2 < time3))
        XCTAssert(time2 <= time3)
        XCTAssert(!(time2 > time3))
        XCTAssert(time2 >= time3)
        
        // Transitivity
        XCTAssert(time1 < time3)
        XCTAssert(time3 < time4)
        XCTAssert(time1 < time4)
    }
    
    func testArithmetic() {
        let time1 = Time(hour: 10, minute: 30)
        let time2 = Time(hour: 2, minute: 15)
        let time3 = Time(hour: 1, minute: 40)
        
        XCTAssert(time1 + time2 == Time(hour: 12, minute: 45), "Evaluated: \(time1 + time2)")
        XCTAssert(time1 - time3 == Time(hour: 8, minute: 50), "Evaluated: \(time1 - time3)")
        
        let time4 = Time(hour: 23, minute: 55)
        let time5 = Time(hour: 00, minute: 05)
        
        XCTAssert(time4 + time5 == Time(hour: 00, minute: 00), "Evaluated: \(time4 + time5)")
        XCTAssert(time4 + time5 + time5 == Time(hour: 00, minute: 05), "Evaluated: \(time4 + time5 + time5)")
        XCTAssert(time5 - time5 - time5 == Time(hour: 23, minute: 55), "Evaluated: \(time5 - time5 - time5)")
    }
    
    func testSunset() {
        let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
        let sunset = AstronomicalTime(of: .sunset, at: location, for: "2017-02-15")
        let time = Time(from: sunset)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        
        XCTAssert(acceptableTolerance(time, expecting: Time(hour: 17, minute: 21)))
    }

    func acceptableTolerance(_ time: Time, expecting: Time) -> Bool {
        let upperbound = expecting + Time(hour: 0, minute: 5)
        let lowerbound = expecting - Time(hour: 0, minute: 5)
        
        return time >= lowerbound && time <= upperbound
    }

    static var allTests : [(String, (TimeTests) -> () throws -> Void)] {
        return [
            ("testStaticTime", testStaticTime),
            ("testEquality", testEquality),
            ("testComparable", testComparable),
            ("testSunset", testSunset),
        ]
    }
}

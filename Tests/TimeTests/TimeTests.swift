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
    
    func testAstronomicalTime() {
        let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
        
        let time1 = Date().timeIntervalSince1970
    
        let sunset = Time.Astronomic(of: .sunset, at: location, for: .date("2017-02-15"))
        
        let time2 = Date().timeIntervalSince1970
        
        XCTAssert(abs(time1 - time2) < 0.05, "Instancing `sunsetTime` took too long. Potential bug with lazy-like evaluation.")
        
        // Once this line is executed it should wait until the server responds with the time, or a timeout.
        XCTAssert(acceptableTolerance(sunset, expecting: Time(hour: 17, minute: 21)), "Failed. If certain there is no bug check network connection or XCTest multithreading.")
        
        let sunrise = Time.Astronomic(of: .sunrise, at: location, for: .date("2017-02-15"))
        
        XCTAssert(acceptableTolerance(sunrise, expecting: Time(hour: 07, minute: 21)), "Failed. If certain there is no bug check network connection or XCTest multithreading.")
    }
    
    func testAstronomicalTimeCache() {
        /// Run once to fire up the cache
        let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
        
        let startTime1 = Date().timeIntervalSince1970
        let sunset1 = Time.Astronomic(of: .sunset, at: location, for: .date("2014-02-15"))
        let time1 = Time(hour: sunset1.hour, minute: sunset1.minute)
        let stopTime1 = Date().timeIntervalSince1970
        
        let difference1 = stopTime1 - startTime1
        
        
        let startTime2 = Date().timeIntervalSince1970
        let sunset2 = Time.Astronomic(of: .sunset, at: location, for: .date("2014-02-15"))
        let time2 = Time(hour: sunset2.hour, minute: sunset2.minute)
        let stopTime2 = Date().timeIntervalSince1970
        
        let difference2 = stopTime2 - startTime2
        
        XCTAssert(time1 == time2)
        XCTAssert(difference1 > difference2)
    }
    
    func testBetween() {
        let time1 = Time(hour: 5, minute: 00)
        let time2 = Time(hour: 10, minute: 00)
        let time3 = Time(hour: 15, minute: 00)
        
        XCTAssert(time2.isBetween(time1, time3))
        XCTAssert(!time3.isBetween(time2, time1))
    }
    
    func testWrappedBetween() {
        let time1 = Time(hour: 23, minute: 55)
        let time2 = Time(hour: 23, minute: 59)
        let time3 = Time(hour: 00, minute: 00)
        let time4 = Time(hour: 00, minute: 05)
        
        XCTAssert(time2.isWrappedBetween(time1, time3))
        XCTAssert(time2.isWrappedBetween(time1, time4))
        XCTAssert(time3.isWrappedBetween(time1, time4))
        XCTAssert(!time2.isWrappedBetween(time3, time4))
        XCTAssert(time2.isWrappedBetween(time4, time3))
    }
    
    func testOffset() {
        let baseTime = Time(hour: 10, minute: 30)
        let addingOffset = Time.Offset(baseTime, adding: Time(hour: 0, minute: 15))
        XCTAssert(Time(from: addingOffset) == Time(hour: 10, minute: 45))
        
        let chainedOffset = Time.Offset(addingOffset, minus: Time(hour: 1, minute: 30))
        XCTAssert(Time(from: chainedOffset) == Time(hour: 9, minute: 15))
        
        let location = GeographicLocation(latitude: "52.450817", longitude: "-1.930513")
        
        let sunset = Time.Astronomic(of: .sunset, at: location, for: .today)
        let offset = Time.Offset(sunset, minus: sunset)
        
        XCTAssert(Time(from: offset) == Time(hour: 0, minute: 0))
    }
    
    func acceptableTolerance(_ time: TimeRepresentable, expecting: TimeRepresentable) -> Bool {
        let upperbound = Time(from: expecting) + Time(hour: 0, minute: 5)
        let lowerbound = Time(from: expecting) - Time(hour: 0, minute: 5)
        
        return Time(from: time).isBetween(lowerbound, upperbound)
    }

    static var allTests : [(String, (TimeTests) -> () throws -> Void)] {
        return [
            ("testStaticTime", testStaticTime),
            ("testEquality", testEquality),
            ("testComparable", testComparable),
            ("testArithmetic", testArithmetic),
            ("testAstronomicalTime", testAstronomicalTime),
            ("testAstronomicalTimeCache", testAstronomicalTimeCache),
            ("testBetween", testBetween),
            ("testOffset", testOffset),
            ("testWrappedBetween", testWrappedBetween),
        ]
    }
}

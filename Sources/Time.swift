//
//  Time.swift
//
//  Created by Shaun Merchant on 07/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// `Time` represents a point in the day by hour and minute.
/// `Time` utilises `TimeGenerator`s to enable lazy-like evaluation and dynamic time values.
public struct Time: TimeGenerator {
    
    /// The generator of time.
    private var timeGenerator: TimeGenerator
    
    /// The hour of the day.
    public var hour: UInt8 {
        get {
            return self.timeGenerator.hour
        }
    }
    
    /// The minute of the day.
    public var minute: UInt8 {
        get {
            return self.timeGenerator.minute
        }
    }
    
    /// Create a value of time from an hour and minute. 
    ///
    /// - Important: `hour` and `minute` must meet the precondition othewise undefined behaviour will occur
    ///               with subsequent `Time` operations.
    ///
    /// - Precondition: `0 <= hour < 24` and `0 <= minute < 60`
    ///
    /// - Parameters:
    ///   - hour: The hour of the value of time.
    ///   - minute: The minute of the value of time.
    public init(hour: UInt8, minute: UInt8) {
        self.init(from: StaticTime(hour: hour, minute: minute))
    }
    
    /// Create a value of time from a `TimeGenerator`.
    ///
    /// - Parameter generator: The generate to determine time from.
    public init(from generator: TimeGenerator, offset: Int = 0) {
        self.timeGenerator = generator
    }
    
    /// A static generator of time.
    private struct StaticTime: TimeGenerator {
        
        /// The hour of time.
        public let hour: UInt8
        
        /// The minute of time.
        public let minute: UInt8
        
    }

}

extension Time {
    
    /// Add two `Time`s.
    ///
    /// - Parameters:
    ///   - lhs: A value to add.
    ///   - rhs: A value to add.
    /// - Returns: The time value produced when `lhs` is added to `rhs`.
    public static func +(_ lhs: Time, _ rhs: Time) -> Time {
        let minute = lhs.minute &+ rhs.minute               // Since our precondition of minute is 0-59, we can uncheck overflow.
        let overflow = minute % 60
        let carry = minute / 60
        
        let hour = lhs.hour &+ rhs.hour &+ carry   
        if hour > 23 {
            return Time(hour: hour % 24, minute: overflow)
        }
        
        return Time(hour: hour, minute: overflow)
    }
    
    
    /// Substract two `Time`s.
    ///
    /// - Parameters:
    ///   - lhs: A value to subtract.
    ///   - rhs: The value to subtract.
    /// - Returns: The time value produced when `rhs` is subtracted from `lhs`.
    public static func -(lhs: Time, rhs: Time) -> Time {
        var hour = Int8(lhs.hour) &- Int8(rhs.hour)
        var minute = Int8(lhs.minute) &- Int8(rhs.minute)
        let borrow: Int8
        
        if minute < 0 {
            minute = 60 &+ minute
            borrow = -1
        }
        else {
            borrow = 0
        }
        
        hour = hour &+ borrow
        
        if hour < 0 {
            hour = 24 &+ hour
        }
        
        
        return Time(hour: UInt8(hour), minute: UInt8(minute))
    }
}


extension Time {
    
    /// Determine if the value of time is between two given points of time.
    /// `isBetween` treats both values of time as belonding to the same day. 
    /// 
    /// - Example: 13:00 is between 12:00 and 14:00 as 12:00 and 14:00 belong
    ///            to the same day. However, 23:30 is not between 23:00 and 00:00 as 00:00
    ///            belongs to the next day. If forward-propegation of day behaviour is
    ///            required use `isWrappedBetween`.
    ///
    /// - seealso: `public func isWrappedBetween(_: Time, _: Time) -> Bool`
    ///
    /// - Parameters:
    ///   - lhs: The lowerbound of time.
    ///   - rhs: The upperbound of time.
    /// - Returns: Whether the value of time is between two given points of time.
    public func isBetween(_ lhs: Time, _ rhs: Time) -> Bool {
        return lhs <= self && self <= rhs
    }
    
    
    /// Determine if the value of time is between two given points of time.
    /// `isBetween` treats both values of time as forward-propegating, and 
    /// therefore logic is irrespective of day.
    ///
    /// - Example: 23:30 **is** between 23:00 and 00:00 as the lhs vlaue of 23:00
    ///            forward-propegates to the next day value 00:00. However 12:00
    ///            is not between 13:00 and 14:00 as 13:00 terminates forward-propegation
    ///            at the 14:00 value, which 12:00 is not between.
    ///
    /// - Parameters:
    ///   - lhs: The lowerbound of time.
    ///   - rhs: The upperbound of time.
    /// - Returns: Whether the value of time is between two given points of time.
    public func isWrappedBetween(_ lhs: Time, _ rhs: Time) -> Bool {
        return (rhs <= lhs && (lhs <= self || self <= rhs)) || (lhs <= self && self <= rhs)
    }
    
}

// MARK: - Equatable
extension Time: Equatable {
    
    public static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
}

// MARK: - Comparable
extension Time: Comparable {
    
    public static func <(lhs: Time, rhs: Time) -> Bool {
        return (lhs.hour < rhs.hour) || (lhs.hour == rhs.hour && lhs.minute < rhs.minute)
    }

    public static func <=(lhs: Time, rhs: Time) -> Bool {
        return (lhs.hour < rhs.hour) || (lhs.hour == rhs.hour && lhs.minute <= rhs.minute)
    }

    public static func >=(lhs: Time, rhs: Time) -> Bool {
        return (lhs.hour > rhs.hour) || (lhs.hour == rhs.hour && lhs.minute >= rhs.minute)
    }
    
    public static func >(lhs: Time, rhs: Time) -> Bool {
        return (lhs.hour > rhs.hour) || (lhs.hour == rhs.hour && lhs.minute > rhs.minute)
    }
}

// MARK: - Printable
extension Time: CustomStringConvertible {
    
    public var description: String {
        get {
            var output = "T["
            
            if self.hour < 10 {
                output += "0"
            }
            output += "\(self.hour):"
            
            if self.minute < 10 {
                output += "0"
            }
            output += "\(self.minute)"
            
            return output + "]"
        }
    }
    
}

// MARK: - Current Time
extension Time {
    
    /// The current time in the day.
    public static var current: Time {
        get {
            let time = Date()
            let hour = Calendar.current.component(.hour, from: time)
            let minute = Calendar.current.component(.minute, from: time)
            
            return self.init(hour: UInt8(min(hour, 23)), minute: UInt8(min(minute, 59)))
        }
    }
    
}


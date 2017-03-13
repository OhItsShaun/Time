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
    
    /// Create a value of time from an hour and minute. `nil` value will return if the given hour or minute does not meet the precondition.
    ///
    /// - Precondition: `0 <= hour < 24` and `0 <= minute < 60`
    ///
    /// - Parameters:
    ///   - hour: The hour of the value of time.
    ///   - minute: The minute of the value of time.
    init?(hour: UInt8, minute: UInt8) {
        guard (hour >= 0 && hour < 24) && (minute >= 0 && minute < 60) else {
            return nil
        }
        
        self.init(from: StaticTime(hour: hour, minute: minute))
    }
    
    /// Create a value of time from a `TimeGenerator`.
    ///
    /// - Parameter generator: The generate to determine time from.
    init(from generator: TimeGenerator, offset: Int = 0) {
        self.timeGenerator = generator
    }
    
    /// Determine whether the time is between two times.
    ///
    /// - important: Time is treated as cyclic to reflect semantics of time being between points in two days.
    ///
    /// - Example: "11:30 PM" is between "08:00PM" and "01:00 AM" as semantically it is between the previous day and the next day.
    ///
    /// - Parameters:
    ///   - time1: The first time of the day.
    ///   - time2: The second time of the day.
    /// - Returns: Whether the time is between the two times.
    public func between(_ time1: Time, _ time2: Time) -> Bool {
        // Guard that the two times aren't equal..
        guard time1 != time2 else {
            // Otherwise for us to be "between" we must be equal to the times.
            return self == time1
        }
        
        // If the first time is less than the second time
        if time1 < time2 {
            // We know the times aren't equal, but to improve logical efficient checks
            // We'll use `>=` and `<=`
            return self >= time1 && self <= time2
        }
        else {
            // Example:
            //     self = 11pm
            //     t1 = 8pm
            //     t2 = 3am
            //
            // We want to make sure that we are **not** between 8pm and 3am. 
            return !(self < time1 && self > time2)
        }
    }
    
    /// A static generator of time.
    private struct StaticTime: TimeGenerator {
        
        /// The hour of time.
        public let hour: UInt8
        
        /// The minute of time.
        public let minute: UInt8
        
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
            
            return self.init(hour: UInt8(min(hour, 23)), minute: UInt8(min(minute, 59)))!
        }
    }
    
}


//
//  TimeLogic.swift
//  Time
//
//  Created by Shaun Merchant on 27/03/2017.
//
//

import Foundation

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

// MARK: - Between
public extension Time {
    
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

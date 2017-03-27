//
//  TimeMathematics.swift
//  Time
//
//  Created by Shaun Merchant on 27/03/2017.
//

import Foundation

public extension Time {
    
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

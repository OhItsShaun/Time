//
//  Time.swift
//  Time
//
//  Created by Shaun Merchant on 07/02/2017.
//

import Foundation

/// `Time` represents a point in the day by hour and minute.
/// `Time` utilises `TimeRepresentable`s to enable lazy-like evaluation and dynamic time values.
public struct Time: TimeRepresentable {
    
    /// The generator of time.
    private var timeRepresentable: TimeRepresentable
    
    /// The hour of the day.
    public var hour: UInt8 {
        get {
            return self.timeRepresentable.hour
        }
    }
    
    /// The minute of the day.
    public var minute: UInt8 {
        get {
            return self.timeRepresentable.minute
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
        self.init(from: Static(hour: hour, minute: minute))
    }
    
    /// Create a value of time from a `TimeRepresentable`.
    ///
    /// - Important: Be careful with `offset`. Stick to static offsets using `init(hour: UInt8, minute: UInt8)` and not another generator.
    ///
    /// - Parameter representable: The generator to determine time from.
    public init(from representable: TimeRepresentable) {
        self.timeRepresentable = representable
    }
    
    /// A static generator of time.
    private struct Static: TimeRepresentable {
        
        /// The hour of time.
        public let hour: UInt8
        
        /// The minute of time.
        public let minute: UInt8
        
    }
    
}

// MARK: - Printable
extension Time: CustomStringConvertible {
    
    public var description: String {
        get {
            var output = "["
            
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
public extension Time {
    
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

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
        self.init(from: StaticTime(hour: hour, minute: minute))
    }
    
    /// Create a value of time from a `TimeRepresentable`.
    ///
    /// - Important: Be careful with `offset`. Stick to static offsets using `init(hour: UInt8, minute: UInt8)` and not another generator.
    ///
    /// - Parameters:
    ///   - generator: The generator to determine time from.
    ///   - offset: The time to offset the generator value by, `nil` if no offset is required.
    ///   - subtractingOffset: Whether the offset is to be subtracted or not.
    public init(from generator: TimeRepresentable) {
        self.timeRepresentable = generator
    }
    
    /// A static generator of time.
    private struct StaticTime: TimeRepresentable {
        
        /// The hour of time.
        public let hour: UInt8
        
        /// The minute of time.
        public let minute: UInt8
        
    }
    
    /// A generator of time which performs an offset.
    public struct OffsetTime: TimeRepresentable {
        
        private var offset: Time
        private var application: (Time, Time) -> Time
        private var generator: TimeRepresentable
        
        public var hour: UInt8 {
            get {
                return (self.application(Time(hour: generator.hour, minute: generator.minute), offset)).hour
            }
        }
        
        public var minute: UInt8 {
            get {
                return (self.application(Time(hour: generator.hour, minute: generator.minute), offset)).minute
            }
        }
        
        init(offsetBy offset: Time, using application: @escaping (Time, Time) -> Time, generator: TimeRepresentable) {
            self.generator = generator
            self.offset = offset
            self.application = application
        }
        
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

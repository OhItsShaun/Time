//
//  TimeRepresentable.swift
//  Time
//
//  Created by Shaun Merchant on 12/03/2017.
//

import Foundation

/// Conformants to `TimeRepresentable` provides the value of time in hour and minutes.
public protocol TimeRepresentable {
    
    /// The hour of time.
    var hour: UInt8 { get }
    
    /// The minute of time.
    var minute: UInt8 { get }
    
}

public extension TimeRepresentable {
    
    /// The interval between the date object and 00:00 of 1st January 1970.
    public var timeIntervalSince1970: TimeInterval {
        get {
            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            return currentDay + Double(Int(self.hour) * 60 + Int(self.minute)) * 60
        }
    }
    
    
    /// The interval between the date object and 00:00 of the current day.
    public var timeIntervalIntoCurrentDay: TimeInterval {
        get {
            return Double(Int(self.hour) * 60 + Int(self.minute)) * 60
        }
    }
    
}

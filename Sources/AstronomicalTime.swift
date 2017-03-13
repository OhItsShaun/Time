//
//  AstronomicalTimeGenerator.swift
//
//  Created by Shaun Merchant on 12/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import syncDataTask
#if os(Linux)
    import Dispatch
#endif

/// Retrieve the time of an astronomical phase.
///
/// - Important: `AstronomicalTime` requires an active internet connection for HTTP requests and 
///              determines the value of time asynchronously. Therefore when the initialiser returns
///              the value of time has yet to be determined. Requesting `hour` or `minute` before the 
///              the value of time has been determined will result in pause of execution until the value 
///              has been determined or a timeout occurs (5 seconds); whichever event is sooner. In 
///              the event time cannot be determined or timeout occurs the fallback value will be used.
final public class AstronomicalTime: TimeGenerator {
    
    /// Our internal representation of `hour`.
    /// Initially `nil` awaiting for fulfillment from network request or fallback value from error.
    private var _hour: UInt8
    
    /// Our internal representation of `minute`.
    /// Initially `nil` awaiting for fulfillment from network request or fallback value from error.
    private var _minute: UInt8

    /// The location of the astronomical event.
    private let _location: GeographicLocation
    
    public var hour: UInt8 {
        get {
            return self._hour
        }
    }
    
    public var minute: UInt8 {
        get {
            return self._minute
        }
    }
    
    /// Create a new time generator for an astronomical phase.
    ///
    /// - Parameters:
    ///   - phase: The astronomical phase to determine the time of.
    ///   - location: The location of the astronomical phase in the world.
    ///   - day: The date of the astronomical phase.
    public init(of phase: AstronomicalPhase, at location: GeographicLocation, for date: String = "today") {
        self._location = location
        
        let tempTime = phase.fallback()
        self._hour = tempTime.hour
        self._minute = tempTime.minute
        
        DispatchQueue.main.async {
            guard let time = AstronomicalTime.fetchTime(of: phase, at: location, for: date) else {
                return
            }
            self._hour = time.hour
            self._minute = time.minute
        }
    }
    
    /// Astronomincal events in time.
    public enum AstronomicalPhase {
        /// Sunset.
        case sunset
        
        /// Sunrise.
        case sunrise
        
        /// Retrieve a fallback value of time in the case that the actual value of the astronomical phase cannot be resolved.
        ///
        /// - Returns: The fallback value of time.
        public func fallback() -> (hour: UInt8, minute: UInt8) {
            switch self {
            case .sunset:
                return (hour: 18, minute: 00)
            case .sunrise:
                return (hour: 7, minute: 00)
            }
        }
    }
    
}

extension AstronomicalTime {
    
    /// Fetch the time an astronomical phase occurs.
    ///
    /// - Important: `date` **must** be in the format of `"yyyy-MM-dd"`.
    ///
    /// - Parameters:
    ///   - phase: The phase to determine the time of occurance.
    ///   - date: The date of the phase event.
    /// - Returns: The time of the phase event if it could be determined, otherwise nil.
    fileprivate static func fetchTime(of phase: AstronomicalPhase, at location: GeographicLocation, for date: String) -> (hour: UInt8, minute: UInt8)? {
        guard let response = AstronomicalTime.retrieveAstronomy(for: date, at: location) else {
            return nil
        }
        
        switch phase {
        case .sunrise:
            guard let sunriseTime = response["sunrise"] as? String else {
                return nil
            }
            
            return AstronomicalTime.parse(date + " " + sunriseTime)
        case .sunset:
            guard let sunsetTime = response["sunset"] as? String else {
                return nil
            }
            
            return AstronomicalTime.parse(date + " " + sunsetTime)
        }
    }
    
    /// Retrieve astronomical information for a date.
    ///
    /// - Important: `date` **must** be in the format of `"yyyy-MM-dd"`.
    ///
    /// - Parameter date: The date to retrive astronomical information for.
    /// - Returns: The return array of astronomical information, nil otherwise.
    private static func retrieveAstronomy(for date: String, at location: GeographicLocation) -> [String: Any]? {
        guard let url = URL(string: "http://api.sunrise-sunset.org/json?date=" + date + "&lat=" + location.latitude + "&lng=" + location.longitude) else {
            return nil
        }
        
        let (_, data): (URLResponse?, Data?)
        do {
            (_, data) = try URLSession.shared.syncDataTask(with: URLRequest(url: url))
        }
        catch {
            return nil
        }
        
        guard let responseData = data else {
            return nil
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
                return nil
            }
            guard let confirmation = json["status"] as? String, confirmation == "OK" else {
                return nil
                
            }
            guard let results = json["results"] as? [String: Any] else {
                return nil
                
            }
            
            return results
        }
        catch {
            return nil
        }
        
    }
    
    /// Parse a string that contains a time into the value of hour and minutes.
    ///
    /// - Parameter string: The string to parse.
    /// - Returns: The hour and minute value of the time.
    private static func parse(_ string: String) -> (hour: UInt8, minute: UInt8)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        
        // Automagically takes care of TimeZone and Daylight Savings for us. Nice.
        guard let date = dateFormatter.date(from: string) else {
            return nil
        }
        
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
    
        return (hour: UInt8(min(hour, 23)), minute: UInt8(min(minute, 59)))
    }
    
}

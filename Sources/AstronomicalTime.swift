//
//  AstronomicalTimeGenerator.swift
//  House
//
//  Created by Shaun Merchant on 12/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

public class AstronomicalTime: TimeGenerator {
    
    private var _hour: UInt8? = nil
    
    private var _minute: UInt8? = nil

    private let _location: GeographicLocation
    
    public var hour: UInt8 {
        get {
            if self._hour == nil {
                
            }
            
            return self._hour!
        }
    }
    
    public var minute: UInt8 {
        get {
            if self._minute == nil {
                
            }
            
            return self._minute!
        }
    }
    
    public init(of phase: AstronomicalPhase, at location: GeographicLocation, for relativeDay: RelativeDay = .today) {
        self._location = location
        
        DispatchQueue.main.async {
            guard let time = AstronomicalTime.fetchTime(of: phase, at: location, for: relativeDay.rawValue) else {
                let time = phase.fallback()
                self._hour = time.hour
                self._minute = time.minute
                
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
        public func fallback() -> Time {
            switch self {
            case .sunset:
                return Time(hour: 18, minute: 00)!
            case .sunrise:
                return Time(hour: 7, minute: 00)!
            }
        }
    }
    
    public enum RelativeDay: String {
        case today = "today"
        case yesterday = "yesterday"
        case tomorrow = "tomorrow"
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
    fileprivate static func fetchTime(of phase: AstronomicalPhase, at location: GeographicLocation, for date: String) -> Time? {
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
    fileprivate static func retrieveAstronomy(for date: String, at location: GeographicLocation) -> [String: Any]? {
        guard let url = URL(string: "http://api.sunrise-sunset.org/json?date=" + date + "&lat=" + location.latitude + "&lng=" + location.longitude) else {
            return nil
        }
        guard let (_, data) = URLSession.shared.syncHTTPRequest(with: URLRequest(url: url)) else {
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
    fileprivate static func parse(_ string: String) -> Time? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        
        // Automagically takes care of TimeZone and Daylight Savings for us. Nice.
        guard let date = dateFormatter.date(from: string) else {
            return nil
        }
        
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        
        return Time(hour: UInt8(min(hour, 23)), minute: UInt8(min(minute, 59)))
    }
    
}

//
//  AstronomicalTimeGenerator.swift
//  Time
//
//  Created by Shaun Merchant on 12/03/2017.
//

import Foundation
import syncDataTask
#if os(Linux)
    import Dispatch
#endif


public extension Time {
    
    /// Retrieve the time of an astronomical phase.
    ///
    /// - Important: `Astronomic` requires an active internet connection for HTTP requests and
    ///              determines the value of time asynchronously. Therefore when the initialiser returns
    ///              the value of time has yet to be determined. Requesting `hour` or `minute` before the
    ///              the value of time has been determined will result in pause of execution until the value
    ///              has been determined or a timeout occurs (5 seconds); whichever event is sooner. In
    ///              the event time cannot be determined or timeout occurs the fallback value will be used.
    public struct Astronomic: TimeRepresentable {
        
        /// A cache of known sunset and sunrises.
        /// Should contain the previous few days of sunset and sunrise and the next week of sunset and sunrise.
        fileprivate static var _cache = [Date: [AstronomicalPhase: (UInt8, UInt8)]]()
        
        /// Background thread.
        fileprivate static let _dispatch = DispatchQueue(label: "Astronomic", qos: .utility, attributes: .concurrent)
        
        /// The phase we're trying to determine.
        fileprivate let _phase: AstronomicalPhase
        
        /// The location of the astronomical event.
        fileprivate let _location: GeographicLocation
        
        /// The relative date requested.
        fileprivate let _date: Astronomic.RelativeDate
        
        /// Semaphore to delay premature return of hour and minute before the 3rd party has returned
        /// the result. If timeout of 5 seconds, it will default to fallback values.
        fileprivate let _semaphore = DispatchSemaphore(value: 0)
        
        public var hour: UInt8 {
            get {
                if let time = self.retrieveTimeFromCache() {
                    return time.hour
                }
                
                self.dispatchRequest()
                
                let _ = self._semaphore.wait(timeout: DispatchTime.now() + .seconds(3))

                if let time = self.retrieveTimeFromCache() {
                    return time.hour
                }
                else {
                    return self._phase.fallback().hour
                }
            }
        }
        
        public var minute: UInt8 {
            get {
                if let time = self.retrieveTimeFromCache() {
                    return time.minute
                }
                
                self.dispatchRequest()
                
                let _ = self._semaphore.wait(timeout: DispatchTime.now() + .seconds(3))
                
                if let time = self.retrieveTimeFromCache() {
                    return time.minute
                }
                else {
                    return self._phase.fallback().minute
                }
            }
        }
        
        /// Determine the time for an astronomical phase.
        ///
        /// The time of the phase will be localised to the timezone provided in `location`, or if `nil`, the 
        /// timezone of the machine.
        ///
        /// - Important: When using `.date(:String)` it **must** be in the format of `"yyyy-MM-dd"`.
        ///
        /// - Parameters:
        ///   - phase: The astronomical phase to determine the time of.
        ///   - location: The location of the astronomical phase in the world.
        ///   - day: The date of the astronomical phase.
        public init(of phase: AstronomicalPhase, at location: GeographicLocation, for date: Astronomic.RelativeDate = .today) {
            self._location = location
            self._phase = phase
            self._date = date
            self.dispatchRequest()
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
        
        /// A representation of date.
        public enum RelativeDate: CustomStringConvertible {
            
            /// The date for yesterday.
            case yesterday
            
            /// The date for today.
            case today
            
            /// The date for tomorrow.
            case tomorrow
            
            /// Offset the date by a number of days.
            case offset(days: Int)
            
            /// The date value of a formatted string.
            /// - Important: The date must be in the format of `"yyyy-MM-dd"` otherwise runtime error will occur, and unexpected termination is likely.
            case date(_: String)
            
            public var date: Date {
                get {
                    let dateOfStartOfDay = Date.dateOfStartOfDay
                    switch self {
                    case .yesterday:
                        return dateOfStartOfDay.addingTimeInterval(-TimeInterval.secondsInDay)
                    case .today:
                        return dateOfStartOfDay
                    case .tomorrow:
                        return dateOfStartOfDay.addingTimeInterval(TimeInterval.secondsInDay)
                    case .offset(let days):
                        return dateOfStartOfDay.addingTimeInterval(TimeInterval.secondsInDay * Double(days))
                    case .date(let formatted):
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        return dateFormatter.date(from: formatted)!
                    }
                }
            }
            
            public var description: String {
                get {
                    let date = self.date
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    return dateFormatter.string(from: date)
                }
            }
        }
        
    }
}
extension Time.Astronomic {
    
    fileprivate func dispatchRequest() {
        Time.Astronomic._dispatch.async {
            guard let time = self.fetchTime(of: self._phase, at: self._location, for: self._date.description) else {
                return
            }
            
            if Time.Astronomic._cache[self._date.date] == nil {
                Time.Astronomic._cache[self._date.date] = [AstronomicalPhase: (UInt8, UInt8)]()
            }
            Time.Astronomic._cache[self._date.date]![self._phase] = (time.hour, time.minute)
            
            self._semaphore.signal()
            
            guard Time.Astronomic._cache.count > 14 else {
                return
            }
            
            let filtered = Time.Astronomic._cache.filter { (key, _) -> Bool in
                return key > Date.dateOfStartOfDay
            }
            Time.Astronomic._cache.removeAll()
            for (key, value) in filtered {
                Time.Astronomic._cache[key] = value
            }
        }
    }
    
    fileprivate func retrieveTimeFromCache() -> Time? {
        if let phasesTimes = Time.Astronomic._cache[self._date.date], let time = phasesTimes[self._phase] {
            return Time(hour: time.0, minute: time.1)
        }
        
        return nil
    }
    
    /// Fetch the time an astronomical phase occurs.
    ///
    /// - Important: `date` **must** be in the format of `"yyyy-MM-dd"`.
    ///
    /// - Parameters:
    ///   - phase: The phase to determine the time of occurance.
    ///   - date: The date of the phase event.
    /// - Returns: The time of the phase event if it could be determined, otherwise nil.
    fileprivate func fetchTime(of phase: AstronomicalPhase, at location: GeographicLocation, for date: String) -> (hour: UInt8, minute: UInt8)? {
        guard let response = Time.Astronomic.retrieveAstronomy(for: date, at: location) else {
            return nil
        }
        
        switch phase {
        case .sunrise:
            guard let sunriseTime = response["sunrise"] as? String else {
                return nil
            }
            
            return self.parse(date + " " + sunriseTime)
        case .sunset:
            guard let sunsetTime = response["sunset"] as? String else {
                return nil
            }
            
            return self.parse(date + " " + sunsetTime)
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
    private func parse(_ string: String) -> (hour: UInt8, minute: UInt8)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss a"
        
        if let timezone = self._location.timezone {
            dateFormatter.timeZone = timezone
        }
        
        // Automagically takes care of TimeZone and Daylight Savings for us. Nice.
        guard let date = dateFormatter.date(from: string) else {
            return nil
        }
        
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        
        return (hour: UInt8(min(hour, 23)), minute: UInt8(min(minute, 59)))
    }
    
}

fileprivate extension Date {
    
    /// The `Date` value that represents the start of the current day.
    fileprivate static var dateOfStartOfDay: Date {
        get {
            return Calendar.current.startOfDay(for: Date())
        }
    }
    
}

fileprivate extension TimeInterval {
    
    /// The amount of seconds in a day.
    /// - Important: This is constant and not adjsuted for leap seconds.
    fileprivate static var secondsInDay: TimeInterval {
        get {
            return TimeInterval(86400)
        }
    }
    
}

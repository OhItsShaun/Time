//
//  Time-Offset.swift
//  Time
//
//  Created by Shaun Merchant on 27/03/2017.
//
//

import Foundation

public extension Time {
    
    /// A time that is offset by a value.
    public struct Offset: TimeRepresentable {
        
        /// The amount of time to offset the represented time by.
        private var offset: TimeRepresentable
        
        /// The function to apply the offset and represented time.
        private var application: (TimeRepresentable, TimeRepresentable) -> TimeRepresentable
        
        /// The base time which will be offset.
        private var represented: TimeRepresentable
        
        public var hour: UInt8 {
            get {
                return (self.application(Time(hour: represented.hour, minute: represented.minute), offset)).hour
            }
        }
        
        public var minute: UInt8 {
            get {
                return (self.application(Time(hour: represented.hour, minute: represented.minute), offset)).minute
            }
        }
        
        /// Create a time that is offset by a value.
        ///
        /// - Parameters:
        ///     - represented: The base value to offset.
        ///     - offset: The value to offset by.
        ///     - application: The function to apply offset.
        public init(_ represented: TimeRepresentable, by offset: TimeRepresentable, using application: @escaping (TimeRepresentable, TimeRepresentable) -> TimeRepresentable) {
            self.represented = represented
            self.offset = offset
            self.application = application
        }
        
        /// Create a time that is offset by adding a value.
        ///
        /// - Parameters:
        ///     - represented: The base value to offset.
        ///     - offset: The value to add to the base value.
        public init(_ represented: TimeRepresentable, adding offset: TimeRepresentable) {
            self.represented = represented
            self.application = { Time(from: $0) + Time(from: $1) }
            self.offset = offset
        }
        
        /// Create a time that is offset by adding a value.
        ///
        /// - Parameters:
        ///     - represented: The base value to offset.
        ///     - offset: The value to subtract from the base value.
        public init(_ represented: TimeRepresentable, minus offset: TimeRepresentable) {
            self.represented = represented
            self.application = { Time(from: $0) - Time(from: $1) }
            self.offset = offset
            
        }
    }
    
}

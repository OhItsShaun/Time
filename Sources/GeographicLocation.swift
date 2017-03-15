//
//  GeographicLocation.swift
//
//  Created by Shaun Merchant on 12/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A geographic location on Earth, given by longitude and latitude and optional timezone description.
public struct GeographicLocation {
    
    /// The latitude position.
    public var latitude: String
    
    /// The longitude position.
    public var longitude: String
    
    /// The timezone.
    public var timezone: TimeZone?
    
    /// Create a new value of a geographic location.
    ///
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    ///   - timezone: The timezone to handle time in the location.
    init(latitude: String, longitude: String, timezone: TimeZone? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }
}

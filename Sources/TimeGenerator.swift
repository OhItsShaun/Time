//
//  TimeGenerator.swift
//
//  Created by Shaun Merchant on 12/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// Conformants to `TimeGenerator` provides the value of time in hour and minutes.
public protocol TimeGenerator {
    
    /// The hour of time.
    var hour: UInt8 { get }
    
    /// The minute of time.
    var minute: UInt8 { get }
    
}

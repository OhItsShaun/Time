//
//  TimeGenerator.swift
//  House
//
//  Created by Shaun Merchant on 12/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A generator of time.
public protocol TimeGenerator {
    
    /// The hour of time.
    var hour: UInt8 { get }
    
    /// The minute of time.
    var minute: UInt8 { get }
    
}

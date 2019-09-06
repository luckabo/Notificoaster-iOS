//
//  Reading.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-01-15.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import Foundation

class Reading
{
    var createdAt : String
    var deviceId : String
    var temp : Double
    
    init(aDevice: String, aCreatedAt: String, aTemp: Double) {
        deviceId = aDevice
        createdAt = aCreatedAt
        temp = aTemp
    }
}

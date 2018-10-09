//
//  WahooMeasurement.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/8.
//  Copyright © 2018年 Edison. All rights reserved.
//

import Foundation

class WahooMeasurement {
    var instantaneousPower: Int16 = 0
    var speedEventCount: UInt32 = 0
    var speedTime1024: UInt16 = 0
    var cadenceEventCount: UInt16 = 0
    var cadenceTime1024: UInt16 = 0
    
    // wahoo kickr数据解析
    func wahooCyclingPowerMeasurementUpdate(_ data: Data) {
        let bytes = [UInt8] (data)
        
        if bytes.count >= 4 {
            self.instantaneousPower = Int16(bytes[2]) | Int16(bytes[3]) << 8
            if bytes.count >= 12 {
                self.speedEventCount = UInt32(bytes[6]) | UInt32(bytes[7]) << 8 | UInt32(bytes[8]) << 16 | UInt32(bytes[9]) << 24
                self.speedTime1024 = UInt16(bytes[10]) | UInt16(bytes[11]) << 8
                if bytes.count >= 16 {
                    self.cadenceEventCount = UInt16(bytes[12]) | UInt16(bytes[13]) << 8
                    self.cadenceTime1024 = UInt16(bytes[14]) | UInt16(bytes[15]) << 8
                }
            }
        }
    }
}

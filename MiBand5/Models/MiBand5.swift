//
//  MiBand5.swift
//  MiBand5
//
//  Created by Aitor Zubizarreta on 2023-09-23.
//

import Foundation
import CoreBluetooth

struct MiBand5 {
    
    // MARK: - Properties
    
    struct Services_UUID {
        static let device:  CBUUID = CBUUID(string: "FEE0")
        static let battery: CBUUID = CBUUID(string: "0x180F")
    }
    
    struct Characteristics_UUID {
        static let battery: CBUUID = CBUUID(string: "0x2A19")
        static let time:    CBUUID = CBUUID(string: "0x2A2B")
    }
    
    // MARK: - Methods
    
    static func timeCharacteristicDataHandler(data: Data, peripheral: CBPeripheral) {
//        let dataString = String(format: "%02x:%02x", data[0], data[1])
//        print("Data: \(dataString)")
        
        let year :  Int16 = Int16(data[0]) | (Int16(data[1]) << 8)
        let month:  UInt8 = data[2]
        let day:    UInt8 = data[3]
        let hour:   UInt8 = data[4]
        let minute: UInt8 = data[5]
        let second: UInt8 = data[6]
        
        print("⌚️ Date: \(year)/\(month)/\(day) - \(hour):\(minute):\(second)")
        

        ///
        ///Value 0: 231 > e7 > 20
        ///Value 1: 7     > 07 > 23
        ///Value 2: 9 (Month)
        ///Value 3: 23 (Day)
        ///Value 4: 13 (Hour)
        ///Value 5: 1 (Minutes)
        ///Value 6: 36 (Seconds)
        ///
        ///Value 7: 6
        ///Value 8: 0
        ///Value 9: 0
        ///Value 10: 8
        ///
    }
    
    static func batteryCharacteristicDataHandler(data: Data, peripheral: CBPeripheral) {
        if data.count == 1 {
            let battery: UInt8 = data[0]
            print("⌚️ Battery: \(battery)%")
        }
    }
    
}

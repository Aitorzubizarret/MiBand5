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
    }
    
    // MARK: - Methods
    
    static func batteryCharacteristicDataHandler(data: Data, peripheral: CBPeripheral) {
        if data.count == 1 {
            let battery: UInt8 = data[0]
            print("Battery: \(battery)%")
        }
        
        //centralManager?.cancelPeripheralConnection(peripheral)
    }
    
}

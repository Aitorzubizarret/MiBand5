//
//  BLEManagerProtocol.swift
//  MiBand5
//
//  Created by Aitor Zubizarreta on 2023-09-22.
//

import Foundation
import CoreBluetooth

protocol BLEManagerProtocol {
    
    func startScanning()
    
    func searchServices(peripheral: CBPeripheral)
    
}

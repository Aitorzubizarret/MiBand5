//
//  BLEManager.swift
//  MiBand5
//
//  Created by Aitor Zubizarreta on 2023-09-22.
//

import Foundation
import CoreBluetooth

final class BLEManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = BLEManager()
    
    private var centralManager: CBCentralManager?
    private let queue = DispatchQueue(label: "MiBand5")
    private var isOn: Bool = false
    
    private var peripherals: [CBPeripheral] = []
    
    // MARK: - Methods
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: queue)
    }
}

// MARK: - BLEManager Protocol

extension BLEManager: BLEManagerProtocol {
    
    func startScanning() {
        print("BLEManager - startScanning")
        
        if isOn {
            // Chech if there are any peripherals connected.
            if let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [MiBand5.Services_UUID.device]),
               connectedPeripherals.count != 0 {
                print("BLEManager - startScanning \(connectedPeripherals.count) connected peripherals")
                
                for connectedPeripheral in connectedPeripherals {
                    centralManager?.cancelPeripheralConnection(connectedPeripheral)
                }
                
            } else {
                print("BLEManager - startScanning 0 connected periperals")
            }
            
            centralManager?.scanForPeripherals(withServices: [MiBand5.Services_UUID.device])
        }
    }
    
}

// MARK: - CBCentralManager Delegate

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLEManager - centralManagerDidUpdateState")
        
        switch central.state {
        case .unsupported:
            print("Bluetooth State = Unsupported")
            isOn = false
        case .unauthorized:
            print("Bluetooth State = Unauthorized")
            isOn = false
        case .unknown:
            print("Bluetooth State = Unknown")
            isOn = false
        case .resetting:
            print("Bluetooth State = Resetting")
            isOn = false
        case .poweredOff:
            print("Bluetooth State = PoweredOff")
            isOn = false
        case .poweredOn:
            print("Bluetooth State = PoweredOn")
            isOn = true
            
            startScanning()
        default:
            print("Bluetooth State = Default")
            isOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("BLEManager didDiscover peripheral: \(peripheral) - advertisementData: \(advertisementData)")
        
        peripheral.delegate = self
        
        centralManager?.connect(peripheral)
        peripherals.append(peripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BLEManager - didConnect - peripheral: \(peripheral)")
        
        peripheral.discoverServices([])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BLEManager - didDisconnectPeripheral - peripheral: \(peripheral)")
    }
    
}

// MARK: - CBPeripheral Delegate

extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("BLEManager - CBPeripheralDelegate - didDiscoverServices")
        
        guard let services = peripheral.services else { return }
        
        for service in services {
//            print("BLEManager - CBPeripheralDelegate - service: \(service)")
//            peripheral.discoverCharacteristics([], for: service)
            
            if service.uuid == MiBand5.Services_UUID.battery {
                print("BLEManager - CBPeripheralDelegate - service: \(service)")
                peripheral.discoverCharacteristics([], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("🔴 Error didDiscoverCharacteristicsFor: \(error)")
        } else {
            print("🟢 OK didDiscoverCharacteristicsFor")
        }
        
        // Characteristics
        guard let characteristics = service.characteristics else {
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        
        print("BLEManager - CBPeripheralDelegate - didDiscoverCharacteristicsFor")
        
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
        }
        
        //centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("BLEManager - CBPeripheralDelegate - didUpdateValueFor")
        
        guard let data = characteristic.value else {
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        
        print("Characteristic UUID: \(characteristic.uuid)")
        
        switch characteristic.uuid {
        case MiBand5.Characteristics_UUID.battery:
            MiBand5.batteryCharacteristicDataHandler(data: data, peripheral: peripheral)
        default:
            print("Default")
        }
    }
    
    // MARK: - Notifications for Characteristic's value
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("🔴 Error didUpdateNotificationStateFor: \(error)")
        } else {
            print("🟢 OK didUpdateNotificationStateFor")
        }
        
        if characteristic.isNotifying {
            print("🟢🟢 Characteristic is notifying")
        } else {
            print("🔴🔴 Characteristic is NOT notifying")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("🟢🟢 didUpdateValueFor")
    }
    
}

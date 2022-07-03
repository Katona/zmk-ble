//
//  ZmkPer.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 06. 10..
//

import Foundation
import CoreBluetooth
import OSLog

struct HistoricalBatteryValue {
    let date: Date
    let central: UInt8
    let peripheral: UInt8
}

class ZmkPeripheral: NSObject, CBPeripheralDelegate, ObservableObject {
    
    // Indicates that null battery level value meaning it has not been sampled yet.
    private static let NULL_VALUE: UInt8 = 0xFF
    
    private let uuidBatteryService = CBUUID(string: "180F")
    private let uuidBatteryLevelCharacteristic = CBUUID(string: "2A19")
    
    private var cbPeripheral: CBPeripheral!
    private let logger: Logger = Logger();
    
    @Published
    var centralBatteryLevel: UInt8 = 0
    @Published
    var peripheralBatteryLevel: UInt8 = 0
    @Published
    var batteryHistory: [HistoricalBatteryValue] = []
    
    var name: String {
        return cbPeripheral.name!.description
    }
    
    init(cbPeripheral: CBPeripheral, optionalZmkPeripheral: ZmkPeripheral?) {
        super.init()
        self.cbPeripheral = cbPeripheral
        self.cbPeripheral.delegate = self;
        self.cbPeripheral.discoverServices([uuidBatteryService])
        guard let zmkPeripheral = optionalZmkPeripheral else { return }
        self.batteryHistory = zmkPeripheral.batteryHistory
        self.centralBatteryLevel = zmkPeripheral.centralBatteryLevel
        self.peripheralBatteryLevel = zmkPeripheral.peripheralBatteryLevel
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.info("didDiscoverServices");
        let batteryService = peripheral.services?.first(where: { s in s.uuid == uuidBatteryService})
        if batteryService != nil{
            logger.info("Discovered \(batteryService!.description)")
            peripheral.discoverCharacteristics([uuidBatteryLevelCharacteristic], for: batteryService!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.info("didDiscoverCharacteristics")
        service.characteristics?.forEach({characteristics in
            logger.info("Discovered \(characteristics.description)")
            peripheral.discoverDescriptors(for: characteristics)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.info("didUpdateValueForCharacteristic \(characteristic)")
        guard let descriptor = characteristic.descriptors?.first(where: {d in d.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString}) else {
            return
        }
        guard let descriptorValue = getUserDescription(for: descriptor) else {
            return
        }
        
        guard let firstByte = characteristic.value?.first else {
            // handle unexpected empty data
            return
        }
        let batteryLevel = firstByte
      
        if (batteryLevel == ZmkPeripheral.NULL_VALUE) { return }
        
        if (descriptorValue == "Central") {
            centralBatteryLevel = batteryLevel;
        } else if (descriptorValue == "Peripheral") {
            peripheralBatteryLevel = batteryLevel;
        }
        batteryHistory.append(HistoricalBatteryValue(date: Date(), central: centralBatteryLevel, peripheral: peripheralBatteryLevel))
        logger.info("\(descriptorValue) battery level: \(batteryLevel)")
    }
    
    func getUserDescription(for descriptor: CBDescriptor) -> String? {
        var result: String?
        if (descriptor.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString) {
            result = descriptor.value as? String
        }
        return result
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        logger.info("didDiscoverDescriptorsFor")
        guard let userDescriptor = characteristic.descriptors?.first( where: { d in d.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString }) else {
            return
        }
        peripheral.readValue(for: userDescriptor)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        guard let characteristic = descriptor.characteristic else { return }
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
    }
}

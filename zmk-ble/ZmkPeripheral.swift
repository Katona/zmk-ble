//
//  ZmkPer.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 06. 10..
//

import Foundation
import CoreBluetooth
import OSLog


class ZmkPeripheral: NSObject, CBPeripheralDelegate, ObservableObject {
    private let uuidBatteryService = CBUUID(string: "180F")
    private let uuidBatteryLevelCharacteristic = CBUUID(string: "2A19")
    
    private var cbPeripheral: CBPeripheral!
    private let logger: Logger = Logger();
    
    @Published
    private var centralBatteryLevel: UInt8 = 0
    @Published
    private var peripheralBatteryLevel: UInt8 = 0
    
    init(cbPeripheral: CBPeripheral) {
        super.init()
        self.cbPeripheral = cbPeripheral
        self.cbPeripheral.delegate = self;
        self.cbPeripheral.discoverServices([uuidBatteryService])
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
        
        if (descriptorValue == "Central") {
            centralBatteryLevel = batteryLevel;
        } else if (descriptorValue == "Peripheral") {
            peripheralBatteryLevel = batteryLevel;
        }
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

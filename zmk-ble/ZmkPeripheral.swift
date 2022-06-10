//
//  ZmkPer.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 06. 10..
//

import Foundation
import CoreBluetooth
import OSLog

class ZmkPeripheral: NSObject, CBPeripheralDelegate {
    private var cbPeripheral: CBPeripheral!
    private var logger: Logger = Logger();
    
    
    init(cbPeripheral: CBPeripheral) {
        super.init()
        self.cbPeripheral = cbPeripheral
        self.cbPeripheral.delegate = self;
        self.cbPeripheral.discoverServices([CBUUID(string: "180F")])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.info("didDiscoverServices");
        let batteryService = peripheral.services?.first
        if batteryService != nil{
            logger.info("Discovered \(batteryService!.description)")
            peripheral.discoverCharacteristics([CBUUID(string: "2A19")], for: batteryService!)
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
        logger.info("didUpdateValueForCharacteristic")
        characteristic.descriptors?.forEach({d in logger.info("\(self.descriptorDescription(for: d))")})
        guard let firstByte = characteristic.value?.first else {
            // handle unexpected empty data
            return
        }
        let batteryLevel = firstByte
        print("battery level:", batteryLevel)
    }
    
    func descriptorDescription(for descriptor: CBDescriptor) -> String {

        var description: String?
        var value: String?

        switch descriptor.uuid.uuidString {
        case CBUUIDCharacteristicFormatString:
            if let data = descriptor.value as? Data {
                description = "Characteristic format: "
                value = data.description
            }
        case CBUUIDCharacteristicUserDescriptionString:
            if let val = descriptor.value as? String {
                description = "User description: "
                value = val
            }
        case CBUUIDCharacteristicExtendedPropertiesString:
            if let val = descriptor.value as? NSNumber {
                description = "Extended Properties: "
                value = val.description
            }
        case CBUUIDClientCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Client characteristic configuration: "
                value = val.description
            }
        case CBUUIDServerCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Server characteristic configuration: "
                value = val.description
            }
        case CBUUIDCharacteristicAggregateFormatString:
            if let val = descriptor.value as? String {
                description = "Characteristic aggregate format: "
                value = val
            }
        default:
            break
        }

        if let desc=description, let val = value  {
            return "\(desc)\(val)"
        } else {
            return "Unknown descriptor"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        logger.info("didDiscoverDescriptorsFor")
        if characteristic.descriptors?.first(where: {d in d.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString}) != nil {
            peripheral.readValue(for: characteristic)
        }
    }
}

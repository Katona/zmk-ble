//
//  zmk_bleApp.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 05. 31..
//

import SwiftUI
import CoreBluetooth
import OSLog

class PeripheralDelegate : NSObject, CBPeripheralDelegate {
    private var logger: Logger = Logger();

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
            service.peripheral!.readValue(for: characteristics)
        })
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.info("didUpdateValueForCharacteristic")
//        logger.info("\(characteristic.value)")
        guard let firstByte = characteristic.value?.first else {
            // handle unexpected empty data
            return
        }
        let batteryLevel = firstByte
        print("battery level:", batteryLevel)
        
    }
    
}

class DummyDelegate: NSObject, CBCentralManagerDelegate {

    private var logger: Logger = Logger();
    private var peripheralDelegate: CBPeripheralDelegate = PeripheralDelegate()
    private var peripheral: CBPeripheral?
    private var zmkPeripheral: ZmkPeripheral?

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.info("centralManagerDidUpdateState");
        logger.info("\(central.state.rawValue)");
        let peripherals = central.retrieveConnectedPeripherals(withServices: [CBUUID(string: "180F")])
        peripherals.forEach({ p in
            peripheral = p
            logger.info("\(p.identifier)")
//            p.delegate = peripheralDelegate
            central.connect(p)
            
        })
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("connected to \(peripheral.description)")
//        peripheral.discoverServices([CBUUID(string: "180F")])
        self.zmkPeripheral = ZmkPeripheral(cbPeripheral: peripheral)
    }
    
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("haho");
        // 2
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // 3
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "1.circle", accessibilityDescription: "1")
            button.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

@main
struct zmk_bleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate;

    private var cbManager: CBCentralManager
    private var dummyDelegate: DummyDelegate = DummyDelegate()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    init() {
        let log = Logger()
        log.info("Init")
        cbManager = CBCentralManager(delegate: dummyDelegate, queue: nil)

    }
}

//
//  ContentView.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 05. 31..
//

import SwiftUI

struct ContentView: View {
    @StateObject private var peripheral: ZmkPeripheral
    
    init(_ zmkPeripheral: ZmkPeripheral) {
        self._peripheral = StateObject(wrappedValue: zmkPeripheral)
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("C: \(peripheral.centralBatteryLevel)%")
                Text("P: \(peripheral.peripheralBatteryLevel)%")
            }
        }.padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(zmkPeripheral: nil)
//    }
//}

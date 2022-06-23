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
            HStack(spacing: 15) {
                Image(systemName: "keyboard").resizable().aspectRatio(contentMode: .fit).frame(height:30)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Corne").bold()
                    HStack {
                        HStack(spacing: 4) {
                            Text("C").font(.system(size: 10)).padding(4).foregroundColor(Color.white).background(Color.black.opacity(0.6)).clipShape(Circle())
                            Text("\(peripheral.centralBatteryLevel)%")
                        }
                        HStack(spacing: 4) {
                            Text("P").font(.system(size: 10)).padding(4).foregroundColor(Color.white).background(Color.black.opacity(0.6)).clipShape(Circle())
                            Text("\(peripheral.peripheralBatteryLevel)%")
                        }
                    }
                }
            }
        }.padding(15)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(zmkPeripheral: nil)
//    }
//}

//
//  ContentView.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 05. 31..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("Left: 52%")
                Text("Right: 77%")
            }
            
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

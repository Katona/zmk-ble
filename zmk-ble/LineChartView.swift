//
//  LineChartView.swift
//  zmk-ble
//
//  Created by Gabor Hornyak on 2022. 06. 30..
//

import Foundation
import SwiftUI
import Charts

struct BatteryHistoryView: NSViewRepresentable {
    let entries: [HistoricalBatteryValue]
    func makeNSView(context: Context) -> LineChartView {
        let view = LineChartView()
        view.backgroundColor = .white
        view.rightAxis.enabled = false
        view.rightAxis.axisMinimum = 0
        view.xAxis.drawLabelsEnabled = false
        return view
    }
    
    func updateNSView(_ nsView: LineChartView, context: Context) {
        let centralDataSet = LineChartDataSet(entries: entries.map({ e in ChartDataEntry(x: e.date.timeIntervalSince1970, y: Double(e.central))}), label: "Central")
        centralDataSet.colors = [.red]
        centralDataSet.drawCircleHoleEnabled = false
        centralDataSet.drawValuesEnabled = false
        centralDataSet.circleColors = [.red]
        centralDataSet.circleRadius = 2
        let peripheralDataSet = LineChartDataSet(entries: entries.map({ e in ChartDataEntry(x: e.date.timeIntervalSince1970, y: Double(e.peripheral))}), label: "Peripheral")
        peripheralDataSet.colors = [.green]
        peripheralDataSet.drawCircleHoleEnabled = false
        peripheralDataSet.drawValuesEnabled = false
        peripheralDataSet.circleColors = [.green]
        peripheralDataSet.circleRadius = 2
        let chartData = LineChartData(dataSets: [centralDataSet, peripheralDataSet])
        nsView.data = chartData
    }
    
    typealias NSViewType = LineChartView
}

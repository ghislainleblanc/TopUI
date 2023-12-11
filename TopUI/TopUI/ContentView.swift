//
//  ContentView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Charts
import SwiftUI

struct ContentView: View {
    @ObservedObject private var model = ContentModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(model.cpuUsage) { coreUsage in
                        Text("Core \(coreUsage.id): \(Int(coreUsage.usage * 100))%")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Chart {
                    ForEach(model.cpuUsage) { coreUsage in
                        BarMark(
                            x: .value("Core", coreUsage.id),
                            y: .value("Usage", Int(coreUsage.usage * 100))
                        )
                    }
                }
                .frame(width: CGFloat(model.cpuUsage.count * 20))
                .chartXScale(domain: 0...model.cpuUsage.count + 1)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: model.cpuUsage.count)) { value in
                        AxisGridLine()
                        AxisValueLabel("\(value.as(Int.self)!)", anchor: .top)
                    }
                }
                .chartYScale(domain: 0...100)
            }
            .padding(.bottom, 20)

            Divider()
                .padding(.bottom, 20)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                Text("Free Memory: \(String(format: "%.2f", model.memoryUsage.free))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Active Memory: \(String(format: "%.2f", model.memoryUsage.active))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Inactive Memory: \(String(format: "%.2f", model.memoryUsage.inactive))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Wired Memory: \(String(format: "%.2f", model.memoryUsage.wired))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Compressed Memory: \(String(format: "%.2f", model.memoryUsage.compressed))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Total Memory Used: \(String(format: "%.2f", model.memoryUsage.totalMemory()))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Physical Memory: \(String(format: "%.2f", model.memoryUsage.physical))GB")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 20)

            Divider()
                .padding(.bottom, 20)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                Chart {
                    BarMark(
                        x: .value("GPU", 0),
                        y: .value("Usage", model.gpuUsage),
                        width: 80
                    )
                }
                .chartYScale(domain: 0...100)
                .frame(width: 140)
                .padding(.bottom, 6)

                Text("GPU Usage: \(model.gpuUsage)%")
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer()
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 20)
    }
}

#Preview {
    ContentView()
}

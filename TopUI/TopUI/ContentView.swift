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
                .frame(width: 230)
                .chartXScale(domain: 1...13)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 12))
                }
                .chartYScale(domain: 0...100)
            }
            .padding(.bottom, 20)

            VStack(spacing: 0) {
                Text("Free Memory: \(String(format: "%.2f", model.memoryUsage.free))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Active Memory: \(String(format: "%.2f", model.memoryUsage.active))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Inactive Memory: \(String(format: "%.2f", model.memoryUsage.inactive))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Wired Memory: \(String(format: "%.2f", model.memoryUsage.wired))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Compressed Memory: \(String(format: "%.2f", model.memoryUsage.compressed))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Total Memory: \(String(format: "%.2f", model.memoryUsage.totalMemory()))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 20)

            VStack(spacing: 0) {
                Chart {
                    BarMark(
                        x: .value("GPU", 0),
                        y: .value("Usage", model.gpuUsage),
                        width: 30
                    )
                }
                .frame(maxWidth: .infinity)
                .chartYScale(domain: 0...100)
                .padding(.bottom, 6)

                Text("GPU Usage: \(model.gpuUsage)%")
                    .frame(maxWidth: .infinity, alignment: .leading)
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

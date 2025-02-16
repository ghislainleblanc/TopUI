//
//  ContentView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Charts
import SwiftUI

struct ContentView: View {
    @StateObject private var model = ContentModel()

    // swiftlint:disable force_cast
    private let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    // swiftlint:enable force_cast

    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(model.cpuUsage) { coreUsage in
                            Text("Core \(coreUsage.id): \(Int(coreUsage.usage * 100))%")
                                .font(.system(size: 12).bold())
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
                    .frame(width: CGFloat(model.cpuUsage.count * 18))
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
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Active Memory: \(String(format: "%.2f", model.memoryUsage.active))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Inactive Memory: \(String(format: "%.2f", model.memoryUsage.inactive))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Wired Memory: \(String(format: "%.2f", model.memoryUsage.wired))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Compressed Memory: \(String(format: "%.2f", model.memoryUsage.compressed))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Total Allocated Memory: \(String(format: "%.2f", model.memoryUsage.totalMemory))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Physical Memory: \(String(format: "%.2f", model.memoryUsage.physical))GB")
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 20)

                Divider()
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Chart {
                            BarMark(
                                x: .value("Usage", model.gpuUsage),
                                width: 100
                            )
                        }
                        .chartXScale(domain: 0...125)
                        .frame(width: 130, alignment: .leading)
                        .padding(.bottom, 6)

                        Text("GPU Usage: \(model.gpuUsage)%")
                            .font(.system(size: 12).bold())
                            .frame(width: 130, alignment: .leading)
                    }

                    Spacer()

                    VStack(spacing: 0) {
                        Spacer()

                        Text("\(version) (\(bundle))")
                            .font(.footnote)
                            .frame(alignment: .trailing)
                    }
                }

                Spacer()
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
    }
}

#Preview {
    ContentView()
}

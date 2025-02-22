//
//  ContentView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Charts
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

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
                        ForEach(viewModel.cpuUsage) { coreUsage in
                            Text("Core \(coreUsage.id): \(Int(coreUsage.usage * 100))%")
                                .font(.system(size: 10).bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    VStack(spacing: 10) {
                        Chart {
                            ForEach(viewModel.cpuUsage) { coreUsage in
                                BarMark(
                                    x: .value("Core", coreUsage.id),
                                    y: .value("Usage", Int(coreUsage.usage * 100))
                                )
                            }
                        }
                        .frame(width: CGFloat(viewModel.cpuUsage.count * 12))
                        .chartXScale(domain: 0...viewModel.cpuUsage.count + 1)
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: viewModel.cpuUsage.count)) { value in
                                AxisGridLine()
                                AxisValueLabel("\(value.as(Int.self)!)", anchor: .top)
                                    .font(.system(size: 6))
                            }
                        }
                        .chartYScale(domain: 0...100)
                    }
                }

                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)

                VStack(spacing: 0) {
                    Text("Free Memory: \(String(format: "%.2f", viewModel.memoryUsage.free))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Active Memory: \(String(format: "%.2f", viewModel.memoryUsage.active))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Inactive Memory: \(String(format: "%.2f", viewModel.memoryUsage.inactive))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Wired Memory: \(String(format: "%.2f", viewModel.memoryUsage.wired))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Compressed Memory: \(String(format: "%.2f", viewModel.memoryUsage.compressed))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Total Allocated Memory: \(String(format: "%.2f", viewModel.memoryUsage.totalMemory))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Physical Memory: \(String(format: "%.2f", viewModel.memoryUsage.physical))GB")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Network Received: \(Int(viewModel.rxCurrentSpeed.rounded()))KB/s")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Network Sent: \(Int(viewModel.txCurrentSpeed.rounded()))KB/s")
                        .font(.system(size: 10).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Chart {
                            BarMark(
                                x: .value("Usage", viewModel.gpuUsage),
                                width: 100
                            )
                        }
                        .chartXScale(domain: 0...125)
                        .frame(width: 130, alignment: .leading)
                        .padding(.bottom, 6)

                        Text("GPU Usage: \(viewModel.gpuUsage)%")
                            .font(.system(size: 10).bold())
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

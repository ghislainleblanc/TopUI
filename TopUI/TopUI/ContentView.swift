//
//  ContentView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Charts
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    // swiftlint:disable force_cast
    private let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private let bundle = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    // swiftlint:enable force_cast

    private var cpuWidth: CGFloat {
        CGFloat(max(viewModel.cpuUsage.count, 14) * 12)
    }

    private var cpuHeight: CGFloat {
        CGFloat(max(viewModel.cpuUsage.count, 14) * 8)
    }

    var body: some View {
        ZStack {
            GlassShineBackgroundView()
                .ignoresSafeArea()

            VStack {
                HStack {
                    VStack {
                        ForEach(viewModel.cpuUsage) { coreUsage in
                            Text("Core \(coreUsage.id): \(Int(coreUsage.usage * 100))%")
                                .font(.system(size: 10).bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(width: 80)

                    Spacer()

                    VStack {
                        Chart {
                            ForEach(viewModel.cpuUsage) { coreUsage in
                                BarMark(
                                    x: .value("Core", coreUsage.id),
                                    y: .value("Usage", Int(coreUsage.usage * 100))
                                )
                            }
                        }
                        .frame(width: cpuWidth, height: cpuHeight)
                        .chartXScale(domain: 0...viewModel.cpuUsage.count + 1)
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: viewModel.cpuUsage.count)) { value in
                                AxisGridLine()
                                AxisValueLabel("\(value.as(Int.self)!)", anchor: .top)
                                    .font(.system(size: 6))
                            }
                        }
                        .chartYScale(domain: 0...100)

                        VStack {
                            Chart {
                                BarMark(x: .value("Usage", viewModel.gpuUsage))
                            }
                            .chartXScale(domain: 0...100)
                            .frame(width: cpuWidth, height: 40)
                            .padding(.bottom, 6)

                            Text("GPU Usage: \(viewModel.gpuUsage)%")
                                .font(.system(size: 10).bold())
                                .frame(width: cpuWidth, alignment: .leading)
                        }
                    }
                    .padding(.top, 20)
                }

                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)

                HStack {
                    VStack {
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
                    .frame(width: 180)

                    Spacer()

                    VStack {
                        Spacer()

                        Text("\(version) (\(bundle))")
                            .font(.system(size: 6))
                    }
                    .frame(width: 100, alignment: .trailing)
                }
                .frame(height: 120)
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: cpuWidth + 150, maxHeight: cpuHeight + 280)
    }
}

#Preview {
    ContentView()
}

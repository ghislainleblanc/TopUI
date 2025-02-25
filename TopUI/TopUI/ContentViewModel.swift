//
//  ContentViewModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Combine
import Foundation

class ContentViewModel: ObservableObject {
    @Published private(set) var cpuUsage = [CoreUsage]()
    @Published private(set) var memoryUsage = MemoryUsage(
        free: 0,
        active: 0,
        inactive: 0,
        wired: 0,
        compressed: 0,
        physical: 0
    )
    @Published private(set) var gpuUsage = 0
    @Published var rxSpeeds = [Double](repeating: 0, count: 50)
    @Published var txSpeeds = [Double](repeating: 0, count: 50)
    @Published var rxCurrentSpeed: Double = 0
    @Published var txCurrentSpeed: Double = 0

    private let mySystemStats = MySystemStats()

    private var previousNetworkUsage: NetworkUsage?
    private var cancellables = [AnyCancellable]()

    init() {
        mySystemStats.cpuUsagePublisher.sink(receiveValue: { [weak self] cpuUsage in
            self?.cpuUsage = cpuUsage
        })
        .store(in: &cancellables)

        mySystemStats.memoryUsagePublisher.sink(receiveValue: { [weak self] memoryUsage in
            self?.memoryUsage = memoryUsage
        })
        .store(in: &cancellables)

        mySystemStats.gpuUsagePublisher.sink(receiveValue: { [weak self] gpuUsage in
            self?.gpuUsage = gpuUsage
        })
        .store(in: &cancellables)

        mySystemStats.networkUsagePublisher.sink(receiveValue: { [weak self] networkUsage in
            guard let self else { return }

            if let previousNetworkUsage = self.previousNetworkUsage {
                let rxSpeed = (
                    Double(Int(networkUsage.rxBytesPerSecond) - Int(previousNetworkUsage.rxBytesPerSecond)) * 2
                ) / 1024.0
                let txSpeed = (
                    Double(Int(networkUsage.txBytesPerSecond) - Int(previousNetworkUsage.txBytesPerSecond)) * 2
                ) / 1024.0

                if self.rxSpeeds.count > 50 {
                    self.rxSpeeds.removeFirst()
                    self.txSpeeds.removeFirst()
                }

                self.rxSpeeds.append(rxSpeed)
                self.txSpeeds.append(txSpeed)
                self.rxCurrentSpeed = rxSpeed
                self.txCurrentSpeed = txSpeed
            }

            self.previousNetworkUsage = networkUsage
        })
        .store(in: &cancellables)

        mySystemStats.startMonitoring()
    }
}

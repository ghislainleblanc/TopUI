//
//  ContentViewModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Combine
import Foundation

@Observable final class ContentViewModel {
    private(set) var cpuUsage = [CoreUsage]()
    private(set) var memoryUsage = MemoryUsage(
        free: 0,
        active: 0,
        inactive: 0,
        wired: 0,
        compressed: 0,
        total: 0
    )
    private(set) var gpuUsage = 0
    private(set) var rxCurrentSpeed = UInt64.zero
    private(set) var txCurrentSpeed = UInt64.zero

    private let mySystemStats = MySystemStats()

    private var previousNetworkUsage: NetworkUsage?
    private var cancellables = [AnyCancellable]()

    init() {
        mySystemStats
            .$coreUsages
            .assign(to: \.cpuUsage, on: self)
            .store(in: &cancellables)

        mySystemStats
            .$memoryUsage
            .assign(to: \.memoryUsage, on: self)
            .store(in: &cancellables)

        mySystemStats
            .$gpuUsage
            .assign(to: \.gpuUsage, on: self)
            .store(in: &cancellables)

        mySystemStats
            .$networkUsage
            .sink(receiveValue: { [weak self] networkUsage in
                guard let self else { return }

                if let previousNetworkUsage = self.previousNetworkUsage {
                    let rxSpeed = (networkUsage.rxBytesPerSecond - previousNetworkUsage.rxBytesPerSecond) * 2
                    let txSpeed = (networkUsage.txBytesPerSecond - previousNetworkUsage.txBytesPerSecond) * 2

                    self.rxCurrentSpeed = rxSpeed
                    self.txCurrentSpeed = txSpeed
                }

                self.previousNetworkUsage = networkUsage
            })
            .store(in: &cancellables)

        mySystemStats.startMonitoring()
    }
}

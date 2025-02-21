//
//  ContentModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Combine
import Foundation

class ContentModel: ObservableObject {
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
    @Published var rxSpeeds: [Double] = []
    @Published var txSpeeds: [Double] = []

    private let mySystemStats = MySystemStats()

    private var previousNetworkUsage = NetworkUsage(rxBytesPerSecond: 0, txBytesPerSecond: 0)
    private var cancellables = [AnyCancellable]()

    init() {
        mySystemStats.cpuUsagePublisher.sink(receiveValue: { [unowned self] cpuUsage in
            self.cpuUsage = cpuUsage
        })
        .store(in: &cancellables)

        mySystemStats.memoryUsagePublisher.sink(receiveValue: { [unowned self] memoryUsage in
            self.memoryUsage = memoryUsage
        })
        .store(in: &cancellables)

        mySystemStats.gpuUsagePublisher.sink(receiveValue: { [unowned self] gpuUsage in
            self.gpuUsage = gpuUsage
        })
        .store(in: &cancellables)

        mySystemStats.networkUsagePublisher.sink(receiveValue: { [unowned self] networkUsage in
            self.previousNetworkUsage = networkUsage
        })
        .store(in: &cancellables)

        mySystemStats.startMonitoring()
    }
}

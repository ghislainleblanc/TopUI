//
//  ContentModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Combine
import Foundation

class ContentModel: ObservableObject {
    @Published var cpuUsage = [CoreUsage]()
    @Published var memoryUsage = MemoryUsage(free: 0, active: 0, inactive: 0, wired: 0, compressed: 0, physical: 0)
    @Published var gpuUsage = 0

    private let mySystemStats = MySystemStats()

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

        mySystemStats.startMonitoring()
    }
}

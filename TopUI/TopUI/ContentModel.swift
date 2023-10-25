//
//  ContentModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Combine
import Foundation

class ContentModel: ObservableObject {
    @Published var coreUsages = [CoreUsage]()
    @Published var memoryUsage = MemoryUsage(free: 0, active: 0, inactive: 0, wired: 0, compressed: 0)

    private let mySystemStats = MySystemStats()

    private var cancellables = [AnyCancellable]()

    init() {
        mySystemStats.coreUsagesPublisher.sink(receiveValue: { [weak self] coreUsages in
            self?.coreUsages = coreUsages
        })
        .store(in: &cancellables)

        mySystemStats.memoryUsagePublisher.sink(receiveValue: { [weak self] memoryUsage in
            self?.memoryUsage = memoryUsage
        })
        .store(in: &cancellables)

        mySystemStats.startMonitoring()
    }
}

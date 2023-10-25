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
    @Published var memoryUsage: MemoryUsage?

    private let myCPUUsage = MyCPUUsage()

    private var cancellables = [AnyCancellable]()

    init() {
        myCPUUsage.coreUsagesPublisher.sink(receiveValue: { [weak self] coreUsages in
            self?.coreUsages = coreUsages
        })
        .store(in: &cancellables)

        myCPUUsage.memoryUsagePublisher.sink(receiveValue: { [weak self] memoryUsage in
            self?.memoryUsage = memoryUsage
        })
        .store(in: &cancellables)

        myCPUUsage.startMonitoring()
    }
}

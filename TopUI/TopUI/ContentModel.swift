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

    private let myCPUUsage = MyCPUUsage()
    private var cancellable: AnyCancellable?

    init() {
        cancellable = myCPUUsage.coreUsagesPublisher.sink(receiveValue: { [weak self] coreUsages in
            self?.coreUsages = coreUsages
        })

        myCPUUsage.startMonitoring()
    }
}

//
//  ContentModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Foundation

@MainActor
class ContentModel: ObservableObject {
    private let myCPUUsage = MyCPUUsage()

    var cpuInfo: processor_info_array_t {
        self.myCPUUsage.cpuInfo
    }
}

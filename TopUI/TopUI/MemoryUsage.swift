//
//  MemoryUsage.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Foundation

struct MemoryUsage {
    let free: Double
    let active: Double
    let inactive: Double
    let wired: Double
    let compressed: Double
    let physical: Double

    var totalMemory: Double {
        free + active + inactive + wired + compressed
    }
}

//
//  MemoryUsage.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Foundation

struct MemoryUsage {
    let free: UInt64
    let active: UInt64
    let inactive: UInt64
    let wired: UInt64
    let compressed: UInt64
    let total: UInt64
}

//
//  Int+Extensions.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2025-06-13.
//

import Foundation

extension Int64 {
    func formattedSize(countStyle: ByteCountFormatter.CountStyle) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = countStyle
        return formatter.string(fromByteCount: self)
    }
}

extension UInt64 {
    func formattedSize(countStyle: ByteCountFormatter.CountStyle) -> String {
        guard self < Int64.max else {
            return "Int64 Overflow"
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = countStyle
        return formatter.string(fromByteCount: Int64(self))
    }
}

//
//  Duration+Units.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/5/24.
//

import Foundation

extension Duration {
    var smartFormatted: String {
        let components = self.components
        let totalAttoseconds = Double(components.seconds) * 1e18 + Double(components.attoseconds)

        // Convert to nanoseconds
        let nanoseconds = totalAttoseconds / 1e9

        switch abs(nanoseconds) {
        case 0..<1:
            // If less than 1ns, show attoseconds
            return String(format: "%.2f as", totalAttoseconds)
        case 1..<1_000:
            // Nanoseconds for 1ns to 1μs
            return String(format: "%.2f ns", nanoseconds)
        case 1_000..<1_000_000:
            // Microseconds for 1μs to 1ms
            return String(format: "%.2f μs", nanoseconds / 1_000)
        case 1_000_000..<1_000_000_000:
            // Milliseconds for 1ms to 1s
            return String(format: "%.2f ms", nanoseconds / 1_000_000)
        case 1_000_000_000..<60_000_000_000:
            // Seconds for 1s to 1 minute
            return String(format: "%.2f s", nanoseconds / 1_000_000_000)
        case 60_000_000_000..<3_600_000_000_000:
            // Minutes for 1 minute to 1 hour
            return String(format: "%.2f min", nanoseconds / (60_000_000_000))
        default:
            // Hours for anything larger
            return String(format: "%.2f hr", nanoseconds / (3_600_000_000_000))
        }
    }
}

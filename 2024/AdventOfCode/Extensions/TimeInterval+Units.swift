//
//  TimeInterval+Units.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//
import Foundation

extension TimeInterval {
    var milliseconds: Int {
        return Int(self * 1_000)
    }

    var microseconds: Int {
        return Int(self * 1_000_000)
    }

    var nanoseconds: Int {
        return Int(self * 1_000_000_000)
    }
}

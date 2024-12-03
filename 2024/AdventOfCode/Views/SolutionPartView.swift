//
//  SolutionPartView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//

import SwiftUI

struct SolutionPartView: View {
    let solution: Solution
    let part: SolutionPart

    var body: some View {
        if part == .part1 {
            Text(solution.part1())
                .textSelection(.enabled)
        } else {
            Text(solution.part2())
                .textSelection(.enabled)
        }
    }
}

#Preview {
    SolutionPartView(solution: HistorianHysteria(), part: .part1)
}

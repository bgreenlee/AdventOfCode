//
//  SolutionView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import SwiftUI

struct SolutionView: View {
    let solution: Solution

    var body: some View {
        VStack {
            SolutionPartView(solution: solution, part: .part1)
            SolutionPartView(solution: solution, part: .part2)
        }
        .padding()
    }
}

#Preview {
    SolutionView(solution: HistorianHysteria())
}

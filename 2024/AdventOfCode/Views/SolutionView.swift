//
//  SolutionView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import SwiftUI

struct SolutionView: View {
    let solution: any Solution

    var body: some View {
        VStack {
            Text(solution.part1())
                .textSelection(.enabled)
            Text(solution.part2())
                .textSelection(.enabled)
        }
        .padding()
    }
}

#Preview {
    SolutionView(solution: RedNosedReports())
}

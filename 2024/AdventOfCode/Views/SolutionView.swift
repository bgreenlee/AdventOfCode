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
        VStack(alignment: .leading) {
            Text("Select Input")
                .font(.headline)
                .padding()
            SolutionPartView(solution: solution, part: .part1)
            SolutionPartView(solution: solution, part: .part2)
        }
        .background(.background)
    }
}

#Preview {
    SolutionView(solution: HistorianHysteria())
}

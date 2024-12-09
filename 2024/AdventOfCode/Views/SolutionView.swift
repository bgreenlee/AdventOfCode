//
//  SolutionView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import SwiftUI

struct SolutionView: View {
    @ObservedObject var solution: Solution

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                InputView(solution: solution)
                Spacer()
                LinksView(solution: solution)
            }
            SolutionPartView(solution: solution, part: .part1)
            SolutionPartView(solution: solution, part: .part2)
        }
        .background(.myBackground)
        .onChange(of: solution, initial: true) {
            // make sure something is selected in the picker
            if solution.selectedInput == nil {
                solution.selectedInput = solution.inputs.first
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var selectedInput = solutions.first!.inputs.first!
        var body: some View {
            SolutionView(solution: solutions.first!)
        }
    }
    return Preview()
}

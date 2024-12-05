//
//  SolutionPartView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//

import SwiftUI

struct SolutionPartView: View {
    @ObservedObject var solution: Solution
    let part: SolutionPart

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(part.rawValue)")
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .padding(.bottom)
                Spacer()
                Button("Run", systemImage: "play") {
                    solution.run(part, file: solution.selectedInput?.name ?? "input")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(solution.selectedInput == nil)
                .help(solution.selectedInput == nil ? "Select an input file" : "Run the solution")
            }
            Text("Answer: \(solution.answers[part]?.answer ?? "")")
                .textSelection(.enabled)
            Text("Execution time: \(solution.answers[part] == nil ? "" : "\(solution.answers[part]!.executionTime.smartFormatted)")")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .roundedBorder(.black, width: 1, cornerRadius: 8)
        .padding()

    }
}

#Preview {
    struct Preview: View {
        @State var selectedInput = solutions.first?.inputs.first
        var body: some View {
            SolutionPartView(solution: solutions.first!, part: .part1)
        }
    }
    return Preview()
}

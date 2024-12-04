//
//  SolutionPartView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//

import SwiftUI

struct SolutionPartView: View {
    @StateObject var solution: Solution
    let part: SolutionPart
//    @State private var answer: SolutionAnswer?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(part.rawValue)")
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .padding(.bottom)
                Spacer()
                Button("Run", systemImage: "play") {
                    solution.run(part)
                    // we're only using answer to signal a state change
                    // since updating the solution var doesn't trigger it, as it is a reference
//                    answer = solution.answers[part]
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            Text("Answer: \(solution.answers[part]?.answer ?? "")")
                .textSelection(.enabled)
            Text("Execution time: \(solution.answers[part] == nil ? "" : "\(solution.answers[part]?.executionTime.milliseconds ?? 0) ms")")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .roundedBorder(.black, width: 1, cornerRadius: 8)
        .padding()

    }
}

#Preview {
    SolutionPartView(solution: HistorianHysteria(), part: .part1)
}

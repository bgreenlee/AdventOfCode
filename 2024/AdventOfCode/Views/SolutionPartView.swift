//
//  SolutionPartView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//

import SwiftUI

struct SolutionPartView: View {
    @ObservedObject var solution: Solution
    @State private var showProgressView: Bool = false
    let part: SolutionPart

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(part.rawValue)")
                    .multilineTextAlignment(.leading)
                    .font(Font.Design.heading2())
                    .padding(.bottom)
                Spacer()
                HStack(spacing: 8) {  // Add spacing between spinner and button
                    if showProgressView {
                        ProgressView()
                            .controlSize(.small)
                            .frame(height: 24)
                    }
                    Button {
                        Task {
                            // only show ProgressView if it is taking longer than 100 ms
                            let progressViewTask = Task {
                                try await Task.sleep(nanoseconds: 100_000_000)
                                showProgressView = true
                            }
                            let result = await solution.run(part, file: solution.selectedInput?.name ?? "input")
                            solution.updateUI(part: part, answer: result)
                            progressViewTask.cancel()
                            showProgressView = false
                        }
                    } label: {
                        Text("Run")
                    }
                }
                .disabled(showProgressView || solution.selectedInput == nil)
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .help(solution.selectedInput == nil ? "Select an input file" : "Run the solution")
            }
            Text("Answer: \(solution.answers[part]?.answer ?? "")")
                .textSelection(.enabled)
            Text(
                "Execution time: \(solution.answers[part] == nil ? "" : "\(solution.answers[part]!.executionTime.smartFormatted)")"
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.myBackground)
        .roundedBorder(.textForeground, width: 1, cornerRadius: 8)
        .padding()

        if !(solution.frames[part]?.isEmpty ?? true) {
            SolutionDisplayView(solution: solution, part: part)
        }

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

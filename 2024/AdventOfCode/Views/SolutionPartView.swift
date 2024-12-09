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
                    .font(Font.Design.heading2())
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
        .background(.myBackground)
        .roundedBorder(.textForeground, width: 1, cornerRadius: 8)
        .padding()

        if solution.hasDisplay {
            let displaySize = solution.display[part]?.count(where: { $0 == "\n" }) ?? 0
            let font = switch displaySize {
                case 0...20: Font.Design.body()
                case 21...40: Font.Design.bodySmall()
                case 41...60: Font.Design.bodyXSmall()
                default: Font.Design.bodyXXSmall()
            }

            VStack {
                ScrollView {
                    Text(solution.display[part] ?? "")
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(font)
                }
                .frame(minHeight: 300, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.myBackground)
            .roundedBorder(.textForeground, width: 1, cornerRadius: 8)
            .padding()
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

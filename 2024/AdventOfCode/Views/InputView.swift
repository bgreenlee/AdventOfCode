//
//  InputView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/4/24.
//

import SwiftUI

struct InputView: View {
    @ObservedObject var solution: Solution

    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $solution.selectedInput) {
                ForEach(solution.inputs) { input in
                    Text(input.name).tag(input)
                }
            } label: {
                Text("Input file:")
                    .font(.title2)
            }
            .pickerStyle(.palette)
            .fixedSize()
        }
        .padding()
        .background(.background)
    }
}

#Preview {
    struct Preview: View {
        @State var selectedInput = solutions.first?.inputs.first
        var body: some View {
            InputView(solution: solutions.first!)
        }
    }
    return Preview()
}

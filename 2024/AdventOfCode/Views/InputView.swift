//
//  InputView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/4/24.
//

import SwiftUI

struct InputView: View {
    @ObservedObject var solution: Solution
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            Text("Input file")
                .font(Font.Design.heading2())
            Picker(selection: $solution.selectedInput) {
                ForEach(solution.inputs) { input in
                    Text(input.name).tag(input)
                }
            } label: { }
            .pickerStyle(.segmented)
            .fixedSize()
            .font(Font.Design.body()) // this doesn't seem to work
            .colorMultiply(colorScheme == .dark ? .textForeground : .myBackground)
        }
        .padding()
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

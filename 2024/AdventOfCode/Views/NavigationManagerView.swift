//
//  NavigationManagerView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import SwiftUI

struct NavigationManagerView: View {
    @State private var selected: Solution?

    var body: some View {
        NavigationSplitView() {
            List(solutions, id: \.id, selection: $selected) { item in
                NavigationLink() {
                    SolutionView(solution: item)
                        .navigationTitle("")  // Hide default title
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                Text("AoC Day \(item.id): \(item.name)")
                                    .font(Font.Design.heading1())
                                    .foregroundStyle(.crt)
                            }
                        }
                    Spacer()
                } label: {
                    Text("Day \(item.id): \(item.name)")
                        .font(Font.Design.body())
                        .toolbarBackground(.myBackground)
                }
            }
            .navigationSplitViewColumnWidth(ideal: 240)
            .background(.myBackground)

        } detail: {
            Text("Please select a day.")
                .font(Font.Design.heading2())
                .navigationTitle("")  // Hide default title
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Text("Advent of Code")
                            .font(Font.Design.heading1())
                            .foregroundStyle(.crt)
                    }
                }
                .toolbarBackground(.myBackground)
        }
        .navigationTitle("")
        .background(.myBackground)
        .foregroundStyle(.textForeground)
        .font(Font.Design.body())
    }
}

#Preview {
    NavigationManagerView()
}

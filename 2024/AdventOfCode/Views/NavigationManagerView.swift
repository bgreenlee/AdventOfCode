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
                                Text("Day \(item.id): \(item.name)")
                                    .font(Font.custom("Source Code Pro", size: 20))
                            }
                        }
                    Spacer()
                } label: {
                    Text("Day \(item.id): \(item.name)")
                        .font(Font.custom("Source Code Pro", size: 12))
                }
            }
            .navigationSplitViewColumnWidth(ideal: 220)
            .background(.background)

        } detail: {
            Text("Please select a day.")
                .font(Font.custom("Source Code Pro", size: 24))
                .navigationTitle("")  // Hide default title
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Text("Advent of Code")
                            .font(Font.custom("Source Code Pro", size: 20))
                    }
                }
        }
        .navigationTitle("")
        .background(.background)
        .foregroundColor(.textForeground)
        .font(Font.custom("Source Code Pro", size: 12))
    }
}

#Preview {
    NavigationManagerView()
}

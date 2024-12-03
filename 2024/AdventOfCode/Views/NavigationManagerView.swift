//
//  NavigationManagerView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import SwiftUI

struct NavigationManagerView: View {
    @State private var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selected: AnySolution?

    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(solutions, id: \.id, selection: $selected) { item in
                NavigationLink("Day \(item.id): \(item.name)") {
                    SolutionView(solution: item)
                        .navigationTitle("Advent of Code - Day \(item.id): \(item.name)")
                }
            }
        } detail: {
            Text("Please select a day.")
        }
        .navigationTitle("Advent of Code")
    }
}

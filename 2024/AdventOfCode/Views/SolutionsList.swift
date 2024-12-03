//
//  SolutionsList.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import SwiftUI

struct SolutionsList: View {
    var body: some View {
        List {
            ForEach(solutions, id: \.id) { solution in
                Text(solution.name)
            }
        }
    }
}

#Preview {
    SolutionsList()
}

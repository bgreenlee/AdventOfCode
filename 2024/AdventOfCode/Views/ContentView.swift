//
//  ContentView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            SolutionsList()
            SolutionView(solution: MullItOver())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

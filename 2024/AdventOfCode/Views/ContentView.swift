//
//  ContentView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(RedNosedReports().part1())
                .textSelection(.enabled)
            Text(RedNosedReports().part2())
                .textSelection(.enabled)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

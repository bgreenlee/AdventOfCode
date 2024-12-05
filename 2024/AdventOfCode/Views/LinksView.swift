//
//  LinksView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/5/24.
//

import SwiftUI

struct LinksView: View {
    @ObservedObject var solution: Solution

    var body: some View {
        VStack(alignment: .trailing) {
            Link("Problem Description", destination: URL(string: solution.aocUrl)!)
            Link("Source Code", destination: URL(string: solution.githubUrl)!)
        }
        .padding()
    }
}

#Preview {
    struct Preview: View {
        @State var selectedInput = solutions.first?.inputs.first
        var body: some View {
            LinksView(solution: solutions.first!)
        }
    }
    return Preview()
}

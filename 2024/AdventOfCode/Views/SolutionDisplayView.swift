//
//  SolutionDisplayView.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/14/24.
//

import SwiftUI

struct SolutionDisplayView: View {
    @ObservedObject var solution: Solution
    let part: SolutionPart
    @State var index: Int = 0
    @State var isPlaying: Bool = false
    @State private var frameCount: Int = 0

    var body: some View {
        let frames = solution.frames[part] ?? []
        let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        let displaySize = frames.first?.count(where: { $0 == "\n" }) ?? 0
        let font =
        switch displaySize {
        case 0...20: Font.Design.body()
        case 21...40: Font.Design.bodySmall()
        case 41...60: Font.Design.bodyXSmall()
        default: Font.Design.bodyXXSmall()
        }

        VStack {
            HStack(alignment: .center) {
                Text("Frame: \(index + 1)/\(frameCount)")
                    .onReceive(timer) { _ in
                        frameCount = frames.count
                    }

                Spacer()

                Button() {
                    index = 0
                } label: {
                    Image(systemName: "backward.end")
                }
                .help("Go to the beginning")
                .disabled(index == 0)
                .buttonStyle(.bordered)

                Button() {
                    stepBackward()
                } label: {
                    Image(systemName: "arrowshape.left")
                }
                .help("Step back")
                .buttonRepeatBehavior(.enabled)
                .disabled(index == 0)
                .buttonStyle(.bordered)

                Button() {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause" : "play")
                }
                .help(isPlaying ? "Pause" : "Play")
                .onReceive(timer) { _ in
                    if isPlaying {
                        stepForward()
                    }
                }
                .buttonStyle(.bordered)

                Button() {
                    stepForward()
                } label: {
                    Image(systemName: "arrowshape.right")
                }
                .help("Step forward")
                .buttonRepeatBehavior(.enabled)
                .disabled(index == frames.count - 1)
                .buttonStyle(.bordered)

                Button() {
                    index = frames.count - 1
                } label: {
                    Image(systemName: "forward.end")
                }
                .help("Go to the end")
                .disabled(index == frames.count - 1)
                .buttonStyle(.bordered)
            }
            ScrollView {
                Text(frames[index])
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(font)
                    .textSelection(.enabled)

            }
            .frame(minHeight: 500, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.myBackground)
        .roundedBorder(.textForeground, width: 1, cornerRadius: 8)
        .padding()
    }

    private func stepForward() {
        guard index < (solution.frames[part]?.count ?? 0) - 1 else { return }
        index += 1
    }

    private func stepBackward() {
        guard index > 0 else { return }
        index -= 1
    }
}

#Preview {
    struct Preview: View {
        @State var selectedInput = solutions.first?.inputs.first
        var body: some View {
            SolutionDisplayView(solution: solutions.first!, part: .part1)
        }
    }
    return Preview()
}

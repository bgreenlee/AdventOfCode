import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let p1answer = lines.map({Calculator.solve($0, precedence: .Left)}).reduce(0,+)
    print("Part 1: \(p1answer)")

    let p2answer = lines.map({Calculator.solve($0, precedence: .Plus)}).reduce(0,+)
    print("Part 2: \(p2answer)")

}

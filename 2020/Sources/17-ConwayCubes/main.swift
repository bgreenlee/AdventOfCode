import Foundation
import Shared


if let input = try Bundle.module.readFile("data/test.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }



}

import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    var lobby = Lobby(lines)
    print("Part 1: \(lobby.blackTiles.count)")

    lobby.cycle(100)
    print("Part 2: \(lobby.blackTiles.count)")
}

import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let lobby = Lobby(lines)
    print("Part 1: \(lobby.blackTiles.count)")
}

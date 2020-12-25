import Foundation
import Shared

struct Tile: Hashable, CustomStringConvertible {
    var x:Int
    var y:Int
    var z:Int

    var description: String {
        return "(\(x),\(y),\(z))"
    }

    init(_ x:Int, _ y:Int, _ z:Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    func adjacent(_ dir:String) -> Tile {
        switch dir {
        case "ne": return self + ( 1, 0,-1)
        case "e":  return self + ( 1,-1, 0)
        case "se": return self + ( 0,-1, 1)
        case "sw": return self + (-1, 0, 1)
        case "w":  return self + (-1, 1, 0)
        case "nw": return self + ( 0, 1,-1)
        default:   return self
        }
    }

    static func + (lhs: Tile, rhs: (Int, Int, Int)) -> Tile {
        return Tile(lhs.x + rhs.0, lhs.y + rhs.1, lhs.z + rhs.2)
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}


struct Lobby {
    var blackTiles:Set<Tile> = []

    init(_ input:[String]) {
        let re = try! RegEx(pattern: "(ne|se|nw|sw|e|w)")
        for line in input {
            var tile = Tile(0,0,0)
            let dirs = re.matchGroups(in: line).flatMap({$0})
            for dir in dirs {
                tile = tile.adjacent(dir)
            }
            if blackTiles.contains(tile) {
                blackTiles.remove(tile)
            } else {
                blackTiles.insert(tile)
            }
        }
    }
}

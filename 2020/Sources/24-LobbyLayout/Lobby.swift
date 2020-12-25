import Foundation
import Shared

// Hexagonal Tile
// Using a cube coordinate system (https://www.redblobgames.com/grids/hexagons/#coordinates)
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

    func neighbor(toThe dir:String) -> Tile {
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

    func neighbors() -> Set<Tile> {
        return Set([
            self.neighbor(toThe: "ne"),
            self.neighbor(toThe: "e"),
            self.neighbor(toThe: "se"),
            self.neighbor(toThe: "sw"),
            self.neighbor(toThe: "w"),
            self.neighbor(toThe: "nw"),
        ])
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
                tile = tile.neighbor(toThe: dir)
            }
            if blackTiles.contains(tile) {
                blackTiles.remove(tile)
            } else {
                blackTiles.insert(tile)
            }
        }
    }

    func blackNeighbors(of tile:Tile) -> Set<Tile> {
        return tile.neighbors().intersection(blackTiles)
    }

    func whiteNeighbors(of tile:Tile) -> Set<Tile> {
        return tile.neighbors().subtracting(blackTiles)
    }

    mutating func cycle(_ n:Int = 1) {
        for _ in 1...n {
            var newTiles:Set<Tile> = []
            for tile in blackTiles {
                let bn = blackNeighbors(of: tile)
                if bn.count > 0 && bn.count < 3 {
                    newTiles.insert(tile) // remains black
                }
                for whiteNeighbor in whiteNeighbors(of: tile) {
                    if blackNeighbors(of: whiteNeighbor).count == 2 {
                        newTiles.insert(whiteNeighbor)
                    }
                }
            }
            blackTiles = newTiles
        }
    }
}

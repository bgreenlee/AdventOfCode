import Foundation
import Shared

struct Jigsaw {
    var tiles:Dictionary<Int,[String]> = [:]
    var tileSides:Dictionary<Int,[Int]> = [:]
    var sideTiles:Dictionary<Int,[Int]> = [:]

    init(_ lines:[String]) {
        // read in all the tiles
        var curTile = 0
        for line in lines {
            if line.starts(with: "Tile ") {
                curTile = Int(String(line.dropFirst(5).dropLast(1))) ?? 0
                tiles[curTile] = []
            } else {
                tiles[curTile]?.append(line)
            }
        }

        // calculate the tile sides
        // this is just a straight conversion to binary
        for (tileno, rows) in tiles {
            var sides = [0,0,0,0]
            sides[0] = sideToInt(rows.first!) // top
            sides[2] = sideToInt(rows.last!) // bottom
            var rightChars:[Character] = Array(repeating: "0", count: rows.count)
            var leftChars:[Character] = Array(repeating: "0", count: rows.count)
            for (i, row) in rows.enumerated() {
                leftChars[i] = row.first!
                rightChars[i] = row.last!
            }
            sides[1] = sideToInt(String(rightChars)) // right
            sides[3] = sideToInt(String(leftChars)) // left
            tileSides[tileno] = sides

            for side in sides {
                sideTiles[side, default:[]].append(tileno)
            }
        }
    }

    // convert the side to an integer representation
    // we take the product of the binary representation and its reverse so it
    // is immune to flips
    func sideToInt(_ side:String) -> Int {
        let binary = side.replacingOccurrences(of: ".", with: "0")
                         .replacingOccurrences(of: "#", with: "1")
        let num = Int(binary, radix: 2) ?? -1
        let numReversed = Int(String(binary.reversed()), radix: 2) ?? -1
        return num * numReversed * (num ^ numReversed)
    }

    // find the corner pieces
    // these are tiles that have two sides that don't appear in another tile
    func findCorners() -> [Int] {
        let singletonSides = Set(sideTiles.filter({ (side, tiles) in tiles.count == 1 }).keys)
        return Array(tileSides.filter({ (tile, sides) in
                        singletonSides.intersection(sides).count == 2
                     }).keys)
    }
}

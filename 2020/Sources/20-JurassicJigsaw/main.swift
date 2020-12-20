import Foundation
import Shared

func sideToInt(_ side:String) -> Int {
    let binary = side.replacingOccurrences(of: ".", with: "0")
                     .replacingOccurrences(of: "#", with: "1")
    return Int(binary, radix: 2) ?? -1
}

func leftPad(_ str: String, length: Int, with: String = "0") -> String {
    return String(repeating: with, count: length - str.count) + str
}

// reverse the binary representation of the given number
// and return the decimal version of that
func reverseBinary(_ number:Int, width: Int) -> Int {
    // would be more efficent to do the bit math, but I'm lazy
    let binary = leftPad(String(number, radix: 2), length: width)
    return Int(String(binary.reversed()), radix: 2) ?? -1
}

// rotate sides 90 degrees clockwise
// since we always read sides left-to-right and top-to-bottom, this requires us to
// flip the values of the old left and right sides when they become top and bottom
func rotate(_ sides:[Int]) -> [Int] {
    return [
        reverseBinary(sides[3], width: 10),
        sides[0],
        reverseBinary(sides[1], width: 10),
        sides[2],
    ]
}

// flip the sides left-to-right
// this requires us to flip the values of the top and bottom
func flipLeftRight(_ sides:[Int]) -> [Int] {
    return [
        reverseBinary(sides[0], width: 10),
        sides[3],
        reverseBinary(sides[2], width: 10),
        sides[1],
    ]
}

// flip the sides top-to-bottom
// this requires us to flip the values of the left and right
func flipTopBottom(_ sides:[Int]) -> [Int] {
    return [
        sides[2],
        reverseBinary(sides[1], width: 10),
        sides[0],
        reverseBinary(sides[3], width: 10),
    ]
}

if let input = try Bundle.module.readFile("data/test.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    var tiles:Dictionary<Int,[String]> = [:]
    var tileSides:Dictionary<Int,[Int]> = [:]
    var sideTiles:Dictionary<Int,[Int]> = [:]

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

//    for (tile, sides) in tileSides {
//        print("\(tile): \(sides)")
//    }
    // corners have two sides that are only on one tile
//    print(sideTiles)
//    print("unique sides: \(sideTiles.keys.count)")

    
    let singletonSides = Set(sideTiles.filter({ (side, tiles) in tiles.count == 1 }).keys)
//    print(singletonSides)
    let corners = tileSides.filter({ (tile, sides) in singletonSides.intersection(sides).count == 2 }).keys
//    print(corners)


}

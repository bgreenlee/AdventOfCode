import Foundation
import Shared

struct Tile: Hashable {
    let id: Int
    var image: [String]
    var sides: [Int] // unique code identifying each side
    var top: Int { sides[0] }
    var right: Int { sides[1] }
    var bottom: Int { sides[2] }
    var left: Int { sides[3] }

    init(id: Int, image: [String]) {
        self.id = id
        self.image = image
        self.sides = Tile.calculateSides(image)
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func calculateSides(_ image:[String]) -> [Int] {
        var sides = [0,0,0,0]
        sides[0] = sideToInt(image.first!) // top
        sides[2] = sideToInt(image.last!) // bottom
        var rightChars:[Character] = Array(repeating: "0", count: image.count)
        var leftChars:[Character] = Array(repeating: "0", count: image.count)
        for (i, row) in image.enumerated() {
            leftChars[i] = row.first!
            rightChars[i] = row.last!
        }
        sides[1] = sideToInt(String(rightChars)) // right
        sides[3] = sideToInt(String(leftChars)) // left

        return sides
    }

    // convert the side to an integer representation
    // we take the product of the binary representation and its reverse so it
    // is immune to flips
    static func sideToInt(_ side:String) -> Int {
        let binary = side.replacingOccurrences(of: ".", with: "0")
                         .replacingOccurrences(of: "#", with: "1")
        let num = Int(binary, radix: 2) ?? -1
        let numReversed = Int(String(binary.reversed()), radix: 2) ?? -1
        return num * numReversed * (num ^ numReversed)
    }

    // flip the tile left-to-right
    mutating func flipHoriz() {
        for (i, line) in image.enumerated() {
            image[i] = String(line.reversed())
        }
        sides = [top, left, bottom, right]
    }

    // flip the tile top-to-bottom
    mutating func flipVert() {
        image = image.reversed()
        sides = [bottom, right, top, left]
    }

    // rotate the tile clockwise in 90-degree increments
    mutating func rotate(_ rotations: Int = 1) {
        if rotations < 1 {
            return
        }
        for _ in 1...rotations {
            var newImage:[String] = []
            for i in 0..<image.count {
                var newLine = ""
                for j in 0..<image.count {
                    newLine += image[image.count-j-1][i]
                }
                newImage.append(newLine)
            }
            image = newImage
            sides = [left, top, right, bottom]
        }
    }

    // orient the tile so the given sides are top and left
    mutating func orient(top: Int, left: Int) {
        // orient top
        let topPos = sides.firstIndex(of: top)!
        rotate((4 - topPos) % 4)

        // orient left; we assume top and left are adjacent
        if left != sides[3] {
            flipHoriz()
        }
    }

    // return true if this tile borders the given tile
    func borders(_ tile: Tile) -> Bool {
        Set(sides).intersection(Set(tile.sides)).count > 0
    }

    func imageRemovingBorders() -> [String] {
        image[1..<image.count-1].map { String($0.dropFirst().dropLast()) }
    }

}

struct Jigsaw {
    var tiles:Dictionary<Int,Tile> = [:]
    var tileSides:Dictionary<Int,[Int]> = [:]
    var sideTiles:Dictionary<Int,[Int]> = [:]

    init(_ lines:[String]) {
        // read in all the tiles
        var curId = 0
        var curImage:[String] = []
        for line in lines {
            if line.starts(with: "Tile ") {
                if !curImage.isEmpty {
                    tiles[curId] = Tile(id: curId, image: curImage)
                    curImage = []
                }
                curId = Int(String(line.dropFirst(5).dropLast(1))) ?? 0
            } else {
                curImage.append(line)
            }
        }
        tiles[curId] = Tile(id: curId, image: curImage)

        // generate lookup maps for sides and tiles
        for (id, tile) in tiles {
            tileSides[id] = tile.sides

            for side in tile.sides {
                sideTiles[side, default:[]].append(id)
            }
        }
    }

    func singletonSides(of tile: Tile) -> [Int] {
        return tile.sides.filter({sideTiles[$0]!.count == 1})
    }

    // find the corner pieces
    // these are tiles that have two sides that don't appear in another tile
    func findCorners() -> [Int] {
        let singletonSides = Set(sideTiles.filter({ (side, tiles) in tiles.count == 1 }).keys)
        return Array(tileSides.filter({ (tile, sides) in
                        singletonSides.intersection(sides).count == 2
                     }).keys)
    }

    // find the edge pieces
    // these are tiles that have exactly at least one side that doesn't appear in another tile
    func findEdges() -> [Int] {
        let singletonSides = Set(sideTiles.filter({ (side, tiles) in tiles.count == 1 }).keys)
        return Array(tileSides.filter({ (tile, sides) in
                        singletonSides.intersection(sides).count > 0
                     }).keys)
    }

    // find an edge tile that also matches the given side
    func findEdgeTile(with side:Int, excluding: Set<Tile>) -> Tile {
        let edges = findEdges()
        let edgeTileId = edges.filter({ id in
            let tile = tiles[id]!
            return !excluding.contains(tile) && tile.sides.contains(side)
        }).first!
        return tiles[edgeTileId]!
    }

    // find the tile bordering the given tiles, excluding the given set
    // there should be only one
    func findTile(bordering tiles:(Tile, Tile), excluding: Set<Tile>) -> Tile {
        let matching = Set(self.tiles.values.filter({ $0.borders(tiles.0) && $0.borders(tiles.1)}))
        return matching.subtracting(excluding).first!
    }

    // assemble the puzzle
    func assemble() -> [[Character]] {
        let size = Int(Double(tiles.count).squareRoot())
        var grid:[[Tile]] = []

        for y in 0..<size {
            for x in 0..<size {
                if (x,y) == (0,0) {
                    // start with any corner, assume that is top left
                    var cornerTile = tiles[findCorners().first!]!
                    // rotate it so the singleton sides are top and left
                    let singleSides = singletonSides(of: cornerTile)
                    cornerTile.orient(top: singleSides[0], left: singleSides[1])
                    grid.append([cornerTile])
                } else if x > 0 {
                    // match the tile to the left
                    let leftTile = grid[y][x-1]
                    if y == 0 {
                        let excludeTiles = Set(grid.flatMap({$0}))
                        var tile = findEdgeTile(with: leftTile.right, excluding: excludeTiles)
                        let singleSides = singletonSides(of: tile)
                        if singleSides.count > 1 {
                            // corner piece, two ways to orient
                            tile.orient(top: singleSides[0], left: leftTile.sides[1])
                            if !singleSides.contains(tile.right) {
                                tile.orient(top: singleSides[1], left: leftTile.sides[1])
                            }
                        } else {
                            tile.orient(top: singleSides[0], left: leftTile.sides[1])
                        }
                        grid[0].append(tile)
                    } else {
                        let topTile = grid[y-1][x]
                        var tile = findTile(bordering: (topTile, leftTile), excluding: Set(grid.flatMap({$0})))
                        tile.orient(top: topTile.bottom, left: leftTile.right)
                        grid[y].append(tile)
                    }
                } else {
                    // match the tile above
                    let topTile = grid[y-1][x]
                    let excludeTiles = Set(grid.flatMap({$0}))
                    var tile = findEdgeTile(with: topTile.bottom, excluding: excludeTiles)
                    let singleSides = singletonSides(of: tile)
                    tile.orient(top: topTile.bottom, left: singleSides[0])
                    grid.append([tile])
                }
            }
        }

        // assemble the final puzzle, removing borders
        var lines:[[Character]] = []
        for row in grid {
            let images = row.map({$0.imageRemovingBorders()})
            for i in 0..<images[0].count {
                let line = Array(images.map({Array($0[i])}).joined())
                lines.append(line)
            }
        }
        return lines
    }

    // rotate the puzzle 90 deg clockwise
    static func rotate(image:[[Character]]) -> [[Character]] {
        var newImage:[[Character]] = []
        for i in 0..<image.count {
            var newLine:[Character] = []
            for j in 0..<image.count {
                newLine.append(image[image.count-j-1][i])
            }
            newImage.append(newLine)
        }
        return newImage
    }

    static func findSeadragons(in puzzle:[[Character]]) -> Int {
        var num = 0
        for y in 0..<puzzle.count-4 {
            for x in 18..<puzzle[0].count-1 {
                if puzzle[y][x] == "#" &&
                   puzzle[y+1][x+1] == "#" &&
                   puzzle[y+1][x] == "#" &&
                   puzzle[y+1][x-1] == "#" &&
                   puzzle[y+2][x-2] == "#" &&
                   puzzle[y+2][x-5] == "#" &&
                   puzzle[y+1][x-6] == "#" &&
                   puzzle[y+1][x-7] == "#" &&
                   puzzle[y+2][x-8] == "#" &&
                   puzzle[y+2][x-11] == "#" &&
                   puzzle[y+1][x-12] == "#" &&
                   puzzle[y+1][x-13] == "#" &&
                   puzzle[y+2][x-14] == "#" &&
                   puzzle[y+2][x-17] == "#" &&
                   puzzle[y+1][x-18] == "#"
                {
                    num += 1
                }
            }
        }
        return num
    }
}

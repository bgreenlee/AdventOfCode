//
//  KeypadConundrum.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/31/24.
//

class KeypadConundrum: Solution {
    init() {
        super.init(id: 21, name: "Keypad Conundrum", hasDisplay: true)
    }

    struct Tile: Comparable, Hashable {
        let location: Point
        var cost: Int

        static func < (lhs: Tile, rhs: Tile) -> Bool {
            lhs.cost < rhs.cost
        }

        static func == (lhs: Tile, rhs: Tile) -> Bool {
            lhs.location == rhs.location
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(location)
        }
    }

    func neighbors(_ tile: Tile, _ map: Set<Point>) -> [Tile] {
        var neighbors: [Tile] = []
        let directions: [Vector] = [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]
        for direction in directions {
            let neighborLoc = tile.location &+ direction
            if map.contains(neighborLoc) {
                neighbors.append(Tile(location: neighborLoc, cost: tile.cost + 1))
            }
        }
        return neighbors
    }

    // Dijkstra's algorithm
    func findPath(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [Tile] {
        let INT_MAX = Int.max - 1  // max int minus what we could add to it
        var visited: Set<Tile> = []
        var parents: [Tile: Tile] = [:]
        let startTile = Tile(location: start, cost: 0)
        var pqueue: Set<Tile> = Set([startTile])
        var dists: [Tile: Int] = [startTile: 0]

        while !pqueue.isEmpty {
            let current = pqueue.min(by: { $0.cost < $1.cost })!
            pqueue.remove(current)
            if current.location == goal {
                break
            }
            visited.insert(current)

            for var neighbor in neighbors(current, map) {
                if visited.contains(neighbor) {
                    continue
                }
                let dist = dists[current, default: INT_MAX] + 1
                if dist < dists[neighbor, default: INT_MAX] {
                    parents[neighbor] = current
                    dists[neighbor] = dist
                    neighbor.cost = dist
                    pqueue.insert(neighbor)
                }
            }
        }

        var path: [Tile] = [Tile(location: goal, cost: 0)]
        if var node = parents.first(where: { k, v in k.location == goal })?.value {
            while node != startTile {
                path.append(node)
                node = parents[node]!
            }
            path.append(startTile)
        }
        return path.reversed()
    }

    func findAllPaths(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [[Tile]] {
        let INT_MAX = Int.max - 1
        var visited: Set<Tile> = []
        var parents: [Tile: Set<Tile>] = [:]  // track multiple parents for each node
        let startTile = Tile(location: start, cost: 0)
        var pqueue: Set<Tile> = Set([startTile])
        var dists: [Tile: Int] = [startTile: 0]

        while !pqueue.isEmpty {
            let current = pqueue.min(by: { $0.cost < $1.cost })!
            pqueue.remove(current)
            if current.location == goal {
                break
            }
            visited.insert(current)

            for var neighbor in neighbors(current, map) {
                if visited.contains(neighbor) {
                    continue
                }
                let dist = dists[current, default: INT_MAX] + neighbor.cost
                if dist < dists[neighbor, default: INT_MAX] {
                    // Found a better path - clear existing parents
                    parents[neighbor] = [current]
                    dists[neighbor] = dist
                    neighbor.cost = dist
                    pqueue.insert(neighbor)
                } else if dist == dists[neighbor, default: INT_MAX] {
                    // Found an equal-cost path - add to parents
                    parents[neighbor, default: []].insert(current)
                }
            }
        }

        // build all paths from the parents map
        func buildPaths(from node: Tile) -> [[Tile]] {
            if node == startTile {
                return [[startTile]]
            }

            var paths: [[Tile]] = []
            for parent in parents[node, default: []] {
                let parentPaths = buildPaths(from: parent)
                for var parentPath in parentPaths {
                    parentPath.append(node)
                    paths.append(parentPath)
                }
            }
            return paths
        }

        // find all goal tiles and build paths from each
        let goalTiles = parents.keys.filter { $0.location == goal }
        var allPaths: [[Tile]] = []
        for goalTile in goalTiles {
            allPaths.append(contentsOf: buildPaths(from: goalTile))
        }

        return allPaths
    }

    let numKeypad: [Character: Point] = [
        "7": Point(0, 0), "8": Point(1, 0), "9": Point(2, 0),
        "4": Point(0, 1), "5": Point(1, 1), "6": Point(2, 1),
        "1": Point(0, 2), "2": Point(1, 2), "3": Point(2, 2),
        "0": Point(1, 3), "A": Point(2, 3),
    ]

    let dirKeypad: [Character: Point] = [
        "^": Point(1, 0), "A": Point(2, 0),
        "<": Point(0, 1), "v": Point(1, 1), ">": Point(2, 1),
    ]

    func findNumMoves(for code: String, on keypad: [Character: Point]) -> String {
        var curpos = keypad["A"]!
        var moves: [Character] = []
        for c in code {
            let goal = keypad[c]!
            let dist = goal &- curpos
            if dist.x > 0 {
                moves.append(contentsOf: repeatElement(">", count: dist.x))
            }
            if dist.y < 0 {
                moves.append(contentsOf: repeatElement("^", count: -dist.y))
            }
            if dist.x < 0 {
                moves.append(contentsOf: repeatElement("<", count: -dist.x))
            }
            if dist.y > 0 {
                moves.append(contentsOf: repeatElement("v", count: dist.y))
            }
            moves.append("A")
            curpos = goal
        }
        return String(moves)
    }

    func findDirMoves(for code: String, on keypad: [Character: Point]) -> String {
        var curpos = keypad["A"]!
        var moves: [Character] = []
        for c in code {
            let goal = keypad[c]!
            let dist = goal &- curpos
            if dist.x > 0 {
                moves.append(contentsOf: repeatElement(">", count: dist.x))
            }
            if dist.y > 0 {
                moves.append(contentsOf: repeatElement("v", count: dist.y))
            }
            if dist.x < 0 {
                moves.append(contentsOf: repeatElement("<", count: -dist.x))
            }
            if dist.y < 0 {
                moves.append(contentsOf: repeatElement("^", count: -dist.y))
            }
            moves.append("A")
            curpos = goal
        }
        return String(moves)
    }
    
    override func part1(_ input: [String]) -> String {
        var result = 0
        for code in input {
            var moves = findNumMoves(for: code, on: numKeypad)
            // <A^A>^^AvvvA
            // <A^A>^^AvvvA
            moves = findDirMoves(for: moves, on: dirKeypad)
            // v<<A>>^A<A>AvA<^AA>A<vAAA>^A
            // v<<A>>^A<A>AvA<^AA>Av<AAA>^A
            moves = findDirMoves(for: moves, on: dirKeypad)
            // <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
            // v<A<AA>>^AvAA<^A>Av<<A>>^AvA^Av<A>^Av<<A>^A>AAvA^Av<A<A>>^AAAvA<^A>A
            let codeVal = Int(code.dropLast())!
            result += moves.count * codeVal
            print("\(codeVal): \(moves)")
        }
        return String(result)
    }

    override func part2(_ input: [String]) -> String {
        return ""
    }
}

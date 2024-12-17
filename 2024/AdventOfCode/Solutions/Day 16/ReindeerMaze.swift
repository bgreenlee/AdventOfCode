//
//  ReindeerMaze.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/16/24.
//
import Collections


class ReindeerMaze: Solution {
    init() {
        super.init(id: 16, name: "Reindeer Maze", hasDisplay: true)
    }

    struct Map {
        var grid: Set<Point> = []
        let width: Int
        let height: Int
        let start: Point
        let end: Point

        init(_ input: [String]) {
            var map: Set<Point> = []
            var start = Point(0, 0)
            var end = Point(0, 0)
            for y in 0..<input.count {
                let line = Array(input[y])
                for x in 0..<line.count {
                    switch line[x] {
                    case ".":
                        map.insert(Point(x, y))
                    case "S":
                        map.insert(Point(x, y))
                        start = Point(x, y)
                    case "E":
                        map.insert(Point(x, y))
                        end = Point(x, y)
                    default:
                        break
                    }
                }
            }
            grid = map
            self.start = start
            self.end = end
            self.width = input[0].count
            self.height = input.count
        }
    }

    struct Tile: Comparable, Hashable, CustomStringConvertible {
        let location: Point
        let direction: Vector?
        var fscore: Int
        var description: String {
            let dirStr =
                switch direction {
                case .north:
                    "^"
                case .east:
                    ">"
                case .south:
                    "v"
                case .west:
                    "<"
                default:
                    "?"
                }
            return "(\(location.x), \(location.y)) \(dirStr)"
        }

        static func < (lhs: Tile, rhs: Tile) -> Bool {
            lhs.fscore < rhs.fscore
        }

        static func == (lhs: Tile, rhs: Tile) -> Bool {
            lhs.location == rhs.location && lhs.direction == rhs.direction
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(location)
            hasher.combine(direction)
        }
    }

    func neighbors(_ tile: Tile, _ map: Set<Point>) -> [Tile] {
        var neighbors: [Tile] = []
        let directions: [Vector] = [.north, .east, .south, .west]
        for direction in directions {
            // ignore the opposite direction of this tile...we can't go backwards
            //            if direction == Vector(-tile.direction!.x, -tile.direction!.y) { continue }
            let neighborLoc = tile.location &+ direction
            if map.contains(neighborLoc) {
                let cost =
                    tile.direction == direction
                    ? 1
                    : tile.direction == Vector(-tile.direction!.x, -tile.direction!.y) // opposite, so two turns
                        ? 2001
                        : 1001 // one turn
                neighbors.append(Tile(location: neighborLoc, direction: direction, fscore: cost))
            }
        }
        return neighbors
    }

    // Part 1: Dijkstra's algorithm
    func findPath(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [Tile] {
        let INT_MAX = Int.max - 2001 // max int minus what we could add to it
        var visited: Set<Tile> = []
        var parents: [Tile: Tile] = [:]
        let startTile = Tile(location: start, direction: .east, fscore: 0)
        var pqueue: Heap<Tile> = Heap([startTile])
        var dists: [Tile : Int] = [startTile : 0]

        while !pqueue.isEmpty {
            let current = pqueue.removeMin()
            if current.location == goal {
                break
            }
            visited.insert(current)

            for var neighbor in neighbors(current, map) {
                if visited.contains(neighbor) {
                    continue
                }
                let dist = dists[current, default: INT_MAX] + neighbor.fscore
                if dist < dists[neighbor, default: INT_MAX] {
                    parents[neighbor] = current
                    dists[neighbor] = dist
                    neighbor.fscore = dist
                    pqueue.insert(neighbor)
                }
            }
        }

        var path: [Tile] = []
        var node = parents.first(where: { k, v in k.location == goal})!.value // end node
        while node != startTile {
            path.append(node)
            node = parents[node]!
        }
        path.append(startTile)
        return path.reversed()
    }

    // Part 2: Dijkstra modified to return all best paths
    func findAllPaths(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [[Tile]] {
        let INT_MAX = Int.max - 2001
        var visited: Set<Tile> = []
        var parents: [Tile: Set<Tile>] = [:] // track multiple parents for each node
        let startTile = Tile(location: start, direction: .east, fscore: 0)
        var pqueue: Heap<Tile> = Heap([startTile])
        var dists: [Tile : Int] = [startTile : 0]

        while !pqueue.isEmpty {
            let current = pqueue.removeMin()
            if current.location == goal {
                break
            }
            visited.insert(current)

            for var neighbor in neighbors(current, map) {
                if visited.contains(neighbor) {
                    continue
                }
                let dist = dists[current, default: INT_MAX] + neighbor.fscore
                if dist < dists[neighbor, default: INT_MAX] {
                    // Found a better path - clear existing parents
                    parents[neighbor] = [current]
                    dists[neighbor] = dist
                    neighbor.fscore = dist
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

    func generateFrame(map: Map, path: [Tile]) -> String {
        var string = ""
        for y in 0..<map.height {
            for x in 0..<map.width {
                let point = Point(x, y)
                if point == map.start {
                    string += "S"
                } else if point == map.end {
                    string += "E"
                } else if let tile = path.first(where: { $0.location == point }) {
                    let dirStr =
                        switch tile.direction {
                        case Vector(0, -1):
                            "^"
                        case Vector(1, 0):
                            ">"
                        case Vector(0, 1):
                            "v"
                        case Vector(-1, 0):
                            "<"
                        default:
                            "?"
                        }
                    string += dirStr
                } else if map.grid.contains(point) {
                    string += "."
                } else {
                    string += "#"
                }
            }
            string += "\n"
        }
        return string
    }

    override func part1(_ input: [String]) -> String {
        let map = Map(input)
        let path = findPath(map.grid, map.start, map.end)
        addFrame(part: .part1, generateFrame(map: map, path: path))
        let (score, _) = path.reduce((0, Vector(1, 0))) { acc, tile in
            let (score, direction) = acc
            if tile.direction! == direction {
                return (score + 1, direction)
            } else {
                return (score + 1001, tile.direction!)
            }
        }
        return String(score)
    }

    override func part2(_ input: [String]) -> String {
        let map = Map(input)
        let paths = findAllPaths(map.grid, map.start, map.end)
        let score = Set(paths.flatMap({$0}).map { $0.location }).count
        return String(score)
    }
}

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

    enum Direction: Int {
        case north
        case east
        case south
        case west
    }
    let directions = [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]

    struct Map: CustomStringConvertible {
        var grid: Set<Point> = []
        let width: Int
        let height: Int
        let start: Point
        let end: Point
        var description: String {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    let point = Point(x, y)
                    if point == start {
                        string += "S"
                    } else if point == end {
                        string += "E"
                    } else if grid.contains(point) {
                        string += "."
                    } else {
                        string += "#"
                    }
                }
                string += "\n"
            }
            return string
        }

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
        let fscore: Int
        var description: String {
            let dirStr =
                switch direction {
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

    // cost heuristic for A* - Manhattan distance
    func heuristic(_ start: Tile, _ goal: Tile) -> Int {
        abs(start.location.x - goal.location.x) + abs(start.location.y - goal.location.y)
    }

    func neighbors(_ tile: Tile, _ map: Set<Point>) -> [Tile] {
        var neighbors: [Tile] = []
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

    // A* search algorithm
    func aStar(_ map: Set<Point>, start: Point, goal: Point) -> [Tile] {
        var path: [Tile] = []
        // the set of discovered nodes
        let startTile = Tile(
            location: start, direction: directions[Direction.east.rawValue], fscore: 0)
        let goalTile = Tile(location: goal, direction: nil, fscore: 0)
        var openSet: Heap<Tile> = Heap([startTile])
        var openSetTiles: Set<Tile> = [startTile]  // so we can test for inclusion efficiently
        // for node n, cameFrom[n] is the node immediately preceding it on the cheapest path
        // from start to n currently known
        var cameFrom: [Tile: Tile] = [:]
        // For node n, gscore[n] is the cost of the cheapest path from start to n currently known.
        var gscore: [Tile: Int] = [startTile: 0]
        // For node n, fscore[n] := gscore[n] + heuristic(n, goal). fscore[n] represents our current best guess as to
        // how short a path from start to finish can be if it goes through n.
        var fscore: [Tile: Int] = [startTile: heuristic(startTile, goalTile)]

        while !openSet.isEmpty {
            var current = openSet.popMin()!
            openSetTiles.remove(current)
            if current.location == goal {
                path.append(current)
                while let parent = cameFrom[current] {
                    path.append(parent)
                    current = parent
                }
                return path
            }

            for neighbor in neighbors(current, map) {
                let tentativeGscore = gscore[current]! + neighbor.fscore
                if tentativeGscore < gscore[neighbor, default: Int.max] {
                    // this path to neighbor is better than any previous one
                    cameFrom[neighbor] = current
                    gscore[neighbor] = tentativeGscore
                    fscore[neighbor] = tentativeGscore + heuristic(neighbor, goalTile)
                    if !openSetTiles.contains(neighbor) {
                        openSet.insert(neighbor)
                        openSetTiles.insert(neighbor)
                    }
                }
            }
        }
        return path
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
//        addFrame(part: .part1, map.description)
        let path = aStar(map.grid, start: map.start, goal: map.end).reversed()
        //        print(Array(path))
        addFrame(part: .part1, generateFrame(map: map, path: Array(path)))
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
        return ""
    }
}

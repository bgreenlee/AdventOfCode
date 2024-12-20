//
//  RaceCondition.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/20/24.
//
import Collections

class RaceCondition: Solution {
    init() {
        super.init(id: 20, name: "Race Condition", hasDisplay: true)
    }

    struct Map {
        var grid: Set<Point> = []
        var walls: Set<Point> = []
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
                    case "#":
                        walls.insert(Point(x, y))
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
        var cost: Int
        var description: String {
            return "(\(location.x), \(location.y))"
        }

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
        let directions: [Vector] = [.north, .east, .south, .west]
        for direction in directions {
            // ignore the opposite direction of this tile...we can't go backwards
            //            if direction == Vector(-tile.direction!.x, -tile.direction!.y) { continue }
            let neighborLoc = tile.location &+ direction
            if map.contains(neighborLoc) {
                neighbors.append(Tile(location: neighborLoc, cost: 1))
            }
        }
        return neighbors
    }

    // Dijkstra's algorithm
    func findPath(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [Tile] {
        let INT_MAX = Int.max - 2001 // max int minus what we could add to it
        var visited: Set<Tile> = []
        var parents: [Tile: Tile] = [:]
        let startTile = Tile(location: start, cost: 0)
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
                let dist = dists[current, default: INT_MAX] + neighbor.cost
                if dist < dists[neighbor, default: INT_MAX] {
                    parents[neighbor] = current
                    dists[neighbor] = dist
                    neighbor.cost = dist
                    pqueue.insert(neighbor)
                }
            }
        }

        var path: [Tile] = [Tile(location: goal, cost: 0)]
        var node = parents.first(where: { k, v in k.location == goal})!.value // end node
        while node != startTile {
            path.append(node)
            node = parents[node]!
        }
        path.append(startTile)
        return path.reversed()
    }

    // Manhattan distance
    func distance(_ p1: Point, _ p2: Point) -> Int {
        abs(p1.x - p2.x) + abs(p1.y - p2.y)
    }

    func countCheats(_ input: [String], maxDistance: Int, minSaved: Int) -> Int {
        let map = Map(input)
        let path = findPath(map.grid, map.start, map.end).map { $0.location }
        var score = 0
        for i in 0..<path.count-1 {
            for j in i+1..<path.count {
                let dist = distance(path[i], path[j])
                if dist > 1 && dist <= maxDistance && dist < j - i {
                    if (j - i) - dist >= minSaved {
                        score += 1
                    }
                }
            }
        }
        return score
    }

    override func part1(_ input: [String]) -> String {
        return String(countCheats(input, maxDistance: 2, minSaved: 100))
    }

    override func part2(_ input: [String]) -> String {
        return String(countCheats(input, maxDistance: 20, minSaved: 100))
    }
}

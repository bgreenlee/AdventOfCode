//
//  RAMRun.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/18/24.
//
import Collections

class RAMRun: Solution {
    init() {
        super.init(id: 18, name: "RAM Run", hasDisplay: true)
    }

    struct Map {
        let width: Int
        let height: Int
        let blocks: Set<Point>

        func isOpen(_ point: Point) -> Bool {
            point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
                && !blocks.contains(point)
        }
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

    func neighbors(_ tile: Tile, _ map: Map) -> [Tile] {
        var neighbors: [Tile] = []
        let directions: [Vector] = [.north, .east, .south, .west]
        for direction in directions {
            let neighborLoc = tile.location &+ direction
            if map.isOpen(neighborLoc) {
                neighbors.append(Tile(location: neighborLoc, cost: tile.cost + 1))
            }
        }
        return neighbors
    }

    // Dijkstra's algorithm
    func findPath(_ map: Map, _ start: Point, _ goal: Point) -> [Tile] {
        let INT_MAX = Int.max - 1  // max int minus what we could add to it
        var visited: Set<Tile> = []
        var parents: [Tile: Tile] = [:]
        let startTile = Tile(location: start, cost: 0)
        var pqueue: Heap<Tile> = Heap([startTile])
        var dists: [Tile: Int] = [startTile: 0]

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
                let dist = dists[current, default: INT_MAX] + 1
                if dist < dists[neighbor, default: INT_MAX] {
                    //                    print(neighbor.location)
                    parents[neighbor] = current
                    dists[neighbor] = dist
                    neighbor.cost = dist
                    pqueue.insert(neighbor)
                }
            }
        }

        var path: [Tile] = []
        if var node = parents.first(where: { k, v in k.location == goal })?.value {
            while node != startTile {
                path.append(node)
                node = parents[node]!
            }
            path.append(startTile)
        }
        return path.reversed()
    }

    override func part1(_ input: [String]) -> String {
        let (mapSize, maxBytes) = input.count >= 1024 ? (71, 1024) : (7, 12)  // test case vs. full input
        var bytes = Set<Point>()
        for line in input[..<maxBytes] {
            let coords = line.split(separator: ",").map({ Int($0)! })
            bytes.insert(Point(coords[0], coords[1]))
        }

        let map = Map(width: mapSize, height: mapSize, blocks: bytes)
        let path = findPath(map, Point(0, 0), Point(map.width - 1, map.height - 1))
        return String(path.count)
    }

    override func part2(_ input: [String]) -> String {
        var allBytes: [Point] = []
        for line in input {
            let coords = line.split(separator: ",").map({ Int($0)! })
            allBytes.append(Point(coords[0], coords[1]))
        }

        let mapSize = input.count >= 1024 ? 71 : 7  // test case vs. full input
        var maxBytes = input.count - 1
        while maxBytes > 0 {
            let truncatedBytes = Set(allBytes[...maxBytes])
            let map = Map(width: mapSize, height: mapSize, blocks: truncatedBytes)
            let path = findPath(map, Point(0, 0), Point(map.width - 1, map.height - 1))
            if !path.isEmpty {
                return input[maxBytes + 1]
            }
            maxBytes -= 1
        }
        return ""
    }
}

//
//  GardenGroups.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/12/24.
//

class GardenGroups: Solution {
    init() {
        super.init(id: 12, name: "Garden Groups", hasDisplay: false)
    }

    typealias Map = [Point: Character]
    let cardinalDirections = [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]

    func parseInput(_ input: [String]) -> Map {
        var map: Map = [:]
        for (y, row) in input.enumerated() {
            for (x, char) in row.enumerated() {
                map[Point(x, y)] = char
            }
        }
        return map
    }

    func floodFill(
        _ map: Map, _ point: Point, _ plant: Character, _ visited: inout Map,
        _ region: inout Set<Point>
    ) {
        if map[point] != plant || visited[point] != nil {
            return  // not on map or already visited
        }

        visited[point] = plant
        region.insert(point)

        for dir in cardinalDirections {
            floodFill(map, point &+ dir, plant, &visited, &region)
        }

        return
    }

    // perimeter is just the total number of sides not in the region
    func calculatePerimeter(_ region: Set<Point>) -> Int {
        var perimeter: Int = 0

        for point in region {
            for dir in cardinalDirections {
                if !region.contains(point &+ dir) {
                    perimeter += 1
                }
            }
        }

        return perimeter
    }

    // calculate the number of sides by counting corners
    // a corner has two adjacent sides out of the region, or two
    // adjacent sides in the region, but a diagonal outside
    func calculateSides(_ region: Set<Point>) -> Int {
        var sides: Int = 0

        for point in region {
            for i in 0...3 {
                let p1 = point &+ cardinalDirections[i]
                let p2 = point &+ cardinalDirections[(i + 1) % 4]
                let p3 = point &+ cardinalDirections[i] &+ cardinalDirections[(i + 1) % 4]  // diagonal
                if (!region.contains(p1) && !region.contains(p2))
                    || (region.contains(p1) && region.contains(p2) && !region.contains(p3))
                {
                    sides += 1
                }
            }
        }

        return sides
    }

    func solve(_ input: [String], _ method: (Set<Point>) -> Int) -> Int {
        let map = parseInput(input)
        var regions: [Set<Point>] = []
        var visited: Map = [:]

        for point in map.keys {
            var region: Set<Point> = []
            floodFill(map, point, map[point]!, &visited, &region)
            if !region.isEmpty {
                regions.append(region)
            }
        }

        let price = regions.reduce(0) { acc, region in
            let result = method(region)
            let area = region.count
            return acc + area * result
        }

        return price
    }

    override func part1(_ input: [String]) -> String {
        return String(solve(input, calculatePerimeter))
    }

    override func part2(_ input: [String]) -> String {
        return String(solve(input, calculateSides))
    }
}

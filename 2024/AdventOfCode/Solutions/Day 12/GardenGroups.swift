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
    typealias Region = Set<Point>
    let dirs = [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]

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
        _ map: Map, _ point: Point, _ plant: Character, _ visited: inout Set<Point>, _ region: inout Region
    ) {
        if map[point] != plant || visited.contains(point) {
            return  // not on map or already visited
        }

        visited.insert(point)
        region.insert(point)

        for dir in dirs {
            floodFill(map, point &+ dir, plant, &visited, &region)
        }

        return
    }

    // perimeter is just the total number of sides not in the region
    func calculatePerimeter(_ region: Region) -> Int {
        var perimeter: Int = 0

        for point in region {
            for dir in dirs {
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
    func calculateSides(_ region: Region) -> Int {
        var sides: Int = 0

        for point in region {
            for i in 0...3 {
                let p1 = point &+ dirs[i]
                let p2 = point &+ dirs[(i + 1) % 4]
                let p3 = point &+ dirs[i] &+ dirs[(i + 1) % 4]  // diagonal
                if (!region.contains(p1) && !region.contains(p2))
                    || (region.contains(p1) && region.contains(p2) && !region.contains(p3))
                {
                    sides += 1
                }
            }
        }

        return sides
    }

    func solve(_ input: [String], _ method: (Region) -> Int) -> Int {
        let map = parseInput(input)
        var regions: [Region] = []
        var visited: Set<Point> = []

        for (point, plant) in map {
            var region: Region = []
            floodFill(map, point, plant, &visited, &region)
            if !region.isEmpty {
                regions.append(region)
            }
        }

        let price = regions.reduce(0) { acc, region in
            let area = region.count
            let result = method(region)
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

import Foundation

struct Space {
    var cubes:Set<[Int]> = []

    init(dimensions: Int, rows:[String]) {
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" {
                    var point = Array(repeating: 0, count: dimensions)
                    point[0] = x
                    point[1] = y
                    cubes.update(with: point)
                }
            }
        }
    }

    func neighbors(of point: [Int]) -> Set<[Int]> {
        var neighbors:Set<[Int]> = []
        let max = pow(3, point.count).int - 1
        for n in 0...max {
            if n == max/2 {
                continue // zero point
            }
            // there's surely a better way
            let offsets = String(n, radix: 3).padding(toLength: 3, withPad: "0", startingAt: 0).map { $0.wholeNumberValue! - 1 }
            var newPoint = point
            for i in 0..<offsets.count {
                newPoint[i] += offsets[i]
            }
            neighbors.update(with: newPoint)
        }
        return neighbors
    }

    func activeNeighbors(of point: [Int]) -> Set<[Int]> {
        return neighbors(of: point).intersection(cubes)
    }

    func inactiveNeighbors(of point:  [Int]) -> Set< [Int]> {
        return neighbors(of: point).subtracting(cubes)
    }

    mutating func cycle() {
        var newCubes:Set< [Int]> = []
        for cube in cubes {
            // active cubes
            let numActiveNeighbors = activeNeighbors(of: cube).count
            if numActiveNeighbors == 2 || numActiveNeighbors == 3 {
                newCubes.update(with: cube)
            }

            // inactive cubes
            for inactiveCube in inactiveNeighbors(of: cube) {
                let numActiveNeighbors = activeNeighbors(of: inactiveCube).count
                if numActiveNeighbors == 3 {
                    newCubes.update(with: inactiveCube)
                }
            }
        }
        cubes = newCubes
    }
}

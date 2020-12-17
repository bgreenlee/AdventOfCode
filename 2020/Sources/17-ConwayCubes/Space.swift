import Foundation

struct Space {
    var cubes:Set<Point> = []

    init(_ rows:[String]) {
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" {
                    cubes.update(with: Point(x,y,0))
                }
            }
        }
    }

    func neighbors(of point: Point) -> Set<Point> {
        var neighbors:Set<Point> = []
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    if x == 0 && y == 0 && z == 0 {
                        continue
                    }
                    neighbors.update(with: point + (x,y,z))
                }
            }
        }
        return neighbors
    }

    func activeNeighbors(of point: Point) -> Set<Point> {
        return neighbors(of: point).intersection(cubes)
    }

    mutating func cycle() {
        var newSpace:Set<Point> = []
        // active cubes
        for cube in cubes {
            let numActiveNeighbors = activeNeighbors(of: cube).count
            
        }
    }
}

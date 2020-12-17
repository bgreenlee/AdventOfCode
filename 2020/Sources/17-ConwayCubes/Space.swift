import Foundation

struct Space3D {
    var cubes:Set<Point3D> = []

    init(_ rows:[String]) {
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" {
                    cubes.update(with: Point3D(x,y,0))
                }
            }
        }
    }

    func neighbors(of point: Point3D) -> Set<Point3D> {
        var neighbors:[Point3D] = []
        neighbors.reserveCapacity(26)
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    if (x,y,z) != (0,0,0) {
                        neighbors.append(point + (x,y,z))
                    }
                }
            }
        }
        return Set(neighbors)
    }

    func activeNeighbors(of point: Point3D) -> Set<Point3D> {
        return neighbors(of: point).intersection(cubes)
    }

    func inactiveNeighbors(of point: Point3D) -> Set<Point3D> {
        return neighbors(of: point).subtracting(cubes)
    }

    mutating func cycle(_ n:Int=1) {
        for _ in 0..<n {
            var newCubes:Set<Point3D> = []
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
}

struct Space4D {
    var cubes:Set<Point4D> = []

    init(_ rows:[String]) {
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" {
                    cubes.update(with: Point4D(x,y,0,0))
                }
            }
        }
    }

    func neighbors(of point: Point4D) -> Set<Point4D> {
        var neighbors:[Point4D] = []
        neighbors.reserveCapacity(80)
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    for w in -1...1 {
                        if (x,y,z,w) != (0,0,0,0) {
                            neighbors.append(point + (x,y,z,w))
                        }
                    }
                }
            }
        }
        return Set(neighbors)
    }

    func activeNeighbors(of point: Point4D) -> Set<Point4D> {
        return neighbors(of: point).intersection(cubes)
    }

    func inactiveNeighbors(of point: Point4D) -> Set<Point4D> {
        return neighbors(of: point).subtracting(cubes)
    }

    mutating func cycle(_ n:Int=1) {
        for _ in 0..<n {
            var newCubes:Set<Point4D> = []
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
}

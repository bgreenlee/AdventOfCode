import Foundation
import simd

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
    var cubes:Set<simd_int4> = []
    var neighborCache:Dictionary<simd_int4,Set<simd_int4>> = [:]

    init(_ rows:[String]) {
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "#" {
                    cubes.update(with: simd_make_int4(Int32(x),Int32(y),0,0))
                }
            }
        }
    }

    mutating func neighbors(of point: simd_int4) -> Set<simd_int4> {
        if let cached = neighborCache[point] {
            return cached
        }

        var neighbors:[simd_int4] = []
        neighbors.reserveCapacity(80)
        for x:Int32 in -1...1 {
            for y:Int32 in -1...1 {
                for z:Int32 in -1...1 {
                    for w:Int32 in -1...1 {
                        if (x,y,z,w) != (0,0,0,0) {
                            neighbors.append(point &+ simd_make_int4(x,y,z,w))
                        }
                    }
                }
            }
        }
        neighborCache[point] = Set(neighbors)
        return neighborCache[point]!
    }

    mutating func activeNeighbors(of point: simd_int4) -> Set<simd_int4> {
        return neighbors(of: point).intersection(cubes)
    }

    mutating func inactiveNeighbors(of point: simd_int4) -> Set<simd_int4> {
        return neighbors(of: point).subtracting(cubes)
    }

    mutating func cycle(_ n:Int=1) {
        for _ in 0..<n {
            var newCubes:[simd_int4] = []
            for cube in cubes {
                // active cubes
                let numActiveNeighbors = activeNeighbors(of: cube).count
                if numActiveNeighbors == 2 || numActiveNeighbors == 3 {
                    newCubes.append(cube)
                }

                // inactive cubes
                for inactiveCube in inactiveNeighbors(of: cube) {
                    if activeNeighbors(of: inactiveCube).count == 3 {
                        newCubes.append(inactiveCube)
                    }
                }
            }
            cubes = Set(newCubes)
        }
    }
}

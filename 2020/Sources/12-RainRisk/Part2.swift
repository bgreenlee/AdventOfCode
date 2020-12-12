import Foundation
import Shared

struct Part2 {
    static func solve(_ rows: [String]) -> Int {
        var ship = (0, 0)
        var waypoint = (10, -1)

        for row in rows {
            let cmd = row[0]
            let value = Int(row[1...]) ?? 0
            switch cmd {
            case "N":
                waypoint.1 -= value
            case "S":
                waypoint.1 += value
            case "E":
                waypoint.0 += value
            case "W":
                waypoint.0 -= value
            case "L":
                waypoint = rotate(vec: waypoint, deg: -value)
            case "R":
                waypoint = rotate(vec: waypoint, deg: value)
            case "F":
                ship.0 += value * waypoint.0
                ship.1 += value * waypoint.1
            default:
                continue
            }
        }
        return abs(ship.0) + abs(ship.1)
    }

    static func rotate(vec: (Int, Int), deg: Int) -> (Int, Int) {
        let rad = Float(deg) * Float.pi / 180
        let x2 = cos(rad) * Float(vec.0) - sin(rad) * Float(vec.1)
        let y2 = sin(rad) * Float(vec.0) + cos(rad) * Float(vec.1)
        return (Int(x2.rounded()), Int(y2.rounded()))
    }
}

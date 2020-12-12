import Foundation
import Shared

struct Part1 {
    static func solve(_ rows: [String]) -> Int {
        var distX = 0
        var distY = 0
        var dir = 90
        for row in rows {
            let cmd = row[0]
            let value = Int(row[1...]) ?? 0
            switch cmd {
            case "N":
                distY -= value
            case "S":
                distY += value
            case "E":
                distX += value
            case "W":
                distX -= value
            case "L":
                dir -= value
                dir = (dir + 360) % 360
            case "R":
                dir += value
                dir = (dir + 360) % 360
            case "F":
                switch dir {
                case 0:
                    distY -= value
                case 90:
                    distX += value
                case 180:
                    distY += value
                case 270:
                    distX -= value
                default:
                    print("Unexpected dir value: \(dir)")
                }
            default:
                print("Unexpected command: \(cmd)")
            }
        }
        return abs(distX) + abs(distY)    }
}

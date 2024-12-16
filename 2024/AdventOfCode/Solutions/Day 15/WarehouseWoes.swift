//
//  WarehouseWoes.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/15/24.
//

class WarehouseWoes: Solution {
    init() {
        super.init(id: 15, name: "Warehouse Woes", hasDisplay: true)
    }

    struct Map: CustomStringConvertible {
        let width: Int
        let height: Int
        var grid: [Point: Character] = [:]
        var robot: Point = Point(0, 0)

        var description: String {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    if Point(x, y) == robot {
                        string += "@"
                    } else {
                        string += [grid[Point(x, y), default: "."]]
                    }
                }
                string += "\n"
            }
            return string
        }

        let directions: [Character: Vector] = [
            "^": Vector(0, -1),
            ">": Vector(1, 0),
            "v": Vector(0, 1),
            "<": Vector(-1, 0),
        ]

        init(_ input: ArraySlice<String>) {
            height = input.count
            width = input[0].count

            for y in 0..<height {
                let line = Array(input[y])
                for x in 0..<line.count {
                    if line[x] == "@" {
                        robot = Point(x, y)
                    } else {
                        grid[Point(x, y)] = line[x]
                    }
                }
            }
        }

        mutating func moveRobot(_ direction: Character) {
            let newPos = robot &+ directions[direction, default: Vector(0, 0)]
            let char = grid[newPos]
            switch char {
            case ".":
                grid[robot] = "."
                grid[newPos] = "@"
                robot = newPos
            case "O":
                // see if we can move the box
                moveBlock(newPos, direction)
                if grid[newPos] == "." {
                    moveRobot(direction)
                }
            default:
                break
            }
        }

        mutating func moveBlock(_ pos: Point, _ direction: Character) {
            let newPos = pos &+ directions[direction, default: Vector(0, 0)]
            let char = grid[newPos]
            switch char {
            case ".":
                grid[pos] = "."
                grid[newPos] = "O"
            case "O":
                moveBlock(newPos, direction)
                if grid[newPos] == "." {
                    moveBlock(pos, direction)
                }
            default:
                break
            }
        }
    }

    // parse the input and return the map and the list of moves
    func parseInput(_ input: [String]) -> (Map, [Character]) {
        let splitIndex = input.firstIndex(of: "")!
        let mapInput = input[..<splitIndex]
        let movesInput = input[splitIndex.advanced(by: 1)...]
        return (Map(mapInput), Array(movesInput.joined()))
    }

    override func part1(_ input: [String]) -> String {
        var (map, moves) = parseInput(input)
        addFrame(part: .part1, map.description)
        for move in moves {
            map.moveRobot(move)
//            addFrame(part: .part1, map.description)
        }
        let boxes = map.grid
            .filter({ _, char in char == "O" })
            .map { $0.key }
        let score = boxes.reduce(0) { acc, point in acc + point.x + 100 * point.y }
        return String(score)
    }

    override func part2(_ input: [String]) -> String {
        return ""
    }
}

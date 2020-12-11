import Foundation

struct Point: Hashable {
    var x: Int
    var y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    static func == (l: Point, r: Point) -> Bool {
        return l.x == r.x && l.y == r.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct WaitingArea {
    var width: Int
    var height: Int
    var seats: Dictionary<Point, Bool> = [:]
    var state: Int { seats.hashValue }

    init(_ rows:[String]) {
        width = rows[0].count
        height = rows.count
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                if char == "L" {
                    seats[Point(x,y)] = false
                }
            }
        }
    }

    func immediatelyAdjacent(to point: Point) -> [Point] {
        let possiblyAdjacent = [
            Point(point.x,   point.y-1),
            Point(point.x+1, point.y-1),
            Point(point.x+1, point.y),
            Point(point.x+1, point.y+1),
            Point(point.x,   point.y+1),
            Point(point.x-1, point.y+1),
            Point(point.x-1, point.y),
            Point(point.x-1, point.y-1),
        ]
        return possiblyAdjacent.filter { seats[$0] != nil }
    }

    func visiblyAdjacent(to point: Point) -> [Point] {
        var adjacent: [Point] = []

        // north
        for y in (0..<point.y).reversed() {
            let p = Point(point.x, y)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
        }

        // northeast
        var d = 1
        while point.x + d < width && point.y - d >= 0 {
            let p = Point(point.x + d, point.y - d)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
            d += 1
        }

        // east
        for x in point.x+1..<width {
            let p = Point(x, point.y)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
        }

        // southeast
        d = 1
        while point.x + d < width && point.y + d < height {
            let p = Point(point.x + d, point.y + d)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
            d += 1
        }

        // south
        for y in point.y+1..<height {
            let p = Point(point.x, y)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
        }

        // southwest
        d = 1
        while point.x - d >= 0 && point.y + d < height {
            let p = Point(point.x - d, point.y + d)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
            d += 1
        }

        // west
        for x in (0..<point.x).reversed() {
            let p = Point(x, point.y)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
        }

        // northwest
        d = 1
        while point.x - d >= 0 && point.y - d >= 0 {
            let p = Point(point.x - d, point.y - d)
            if seats[p] != nil {
                adjacent.append(p)
                break
            }
            d += 1
        }

        return adjacent
    }

    func isEmpty(_ point: Point) -> Bool {
        seats[point] == false
    }

    func isOccupied(_ point: Point) -> Bool {
        seats[point] == true
    }

    mutating func cycle(immediate: Bool, occupiedThreshold: Int) {
        var updatedSeats: Dictionary<Point, Bool> = [:]
        for (point, occupied) in seats {
            let adj = immediate ? immediatelyAdjacent(to: point) : visiblyAdjacent(to: point)
            if !occupied && adj.allSatisfy({isEmpty($0)}) {
                updatedSeats[point] = true
            } else if occupied && adj.filter({isOccupied($0)}).count >= occupiedThreshold {
                updatedSeats[point] = false
            }
        }
        seats.merge(updatedSeats, uniquingKeysWith: { (_, new) in new })
    }

    func render() {
        for y in 0..<height {
            for x in 0..<width {
                let p = Point(x, y)
                if let occupied = seats[p] {
                    print(occupied ? "#" : "L", terminator:"")
                } else {
                    print(".", terminator:"")
                }
            }
            print()
        }
    }
}

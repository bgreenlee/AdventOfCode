import Foundation

struct Point: Hashable {
    var x: Int
    var y: Int
    var z: Int

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func + (l: Point, r: (Int, Int, Int)) -> Point {
        return Point(l.x + r.0, l.y + r.1, l.z + r.2)
    }

    static func == (l: Point, r: Point) -> Bool {
        return l.x == r.x && l.y == r.y && l.z == r.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

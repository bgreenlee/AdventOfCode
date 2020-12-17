//import Foundation
//
//struct Point: Hashable {
//    var dimensions:[Int]
//
//    init(_ dimensions: Int...) {
//        self.dimensions = dimensions
//    }
//
//    static func + (l: Point, r: [Int]) -> Point {
//        return Point3D(l.x + r.0, l.y + r.1, l.z + r.2)
//    }
//
//    static func == (l: Point3D, r: Point3D) -> Bool {
//        return l.x == r.x && l.y == r.y && l.z == r.z
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(x)
//        hasher.combine(y)
//        hasher.combine(z)
//    }
//}
//
//struct Point4D: Hashable {
//    var x: Int
//    var y: Int
//    var z: Int
//    var w: Int
//
//    init(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
//        self.x = x
//        self.y = y
//        self.z = z
//        self.w = w
//    }
//
//    static func + (l: Point4D, r: (Int, Int, Int, Int)) -> Point4D {
//        return Point4D(l.x + r.0, l.y + r.1, l.z + r.2, l.w + r.3)
//    }
//
//    static func == (l: Point4D, r: Point4D) -> Bool {
//        return l.x == r.x && l.y == r.y && l.z == r.z && l.w == r.w
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(x)
//        hasher.combine(y)
//        hasher.combine(z)
//        hasher.combine(w)
//    }
//}

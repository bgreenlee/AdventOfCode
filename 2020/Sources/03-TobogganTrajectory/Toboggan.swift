import Foundation

struct Slope {
    var right: Int
    var down: Int
}

struct Toboggan {
    var position: Point = Point(x: 0, y: 0)
    var slope: Slope
    
    init(slope: Slope) {
        self.slope = slope
    }
    
    mutating func move() {
        position.x += slope.right
        position.y += slope.down
    }
}

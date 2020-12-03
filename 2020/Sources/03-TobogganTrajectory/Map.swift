struct Point: Hashable {
    var x: Int
    var y: Int
    
    static func == (l: Point, r: Point) -> Bool {
        return l.x == r.x && l.y == r.y
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct Map {
    var height: Int
    var width: Int
    var trees: Set<Point> = []
    
    init(data: String) {
        let lines = data.components(separatedBy: .newlines).filter { $0.count > 1 } // remove empty lines
        height = lines.count
        width = lines[0].count
        
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                if char == "#" {
                    trees.update(with: Point(x: x, y: y))
                }
            }
        }
    }
    
    func hasTree(at point: Point) -> Bool {
        let wrappedPoint = Point(x: point.x % width, y: point.y)
        return trees.contains(wrappedPoint)
    }
    
    func isInBounds(at point: Point) -> Bool {
        return point.y < height
    }
}

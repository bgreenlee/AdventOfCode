struct Part1 {
    static func run(map: Map) {
        var toboggan = Toboggan(slope: Slope(right: 3, down: 1))
        
        var numTrees = 0
        while map.isInBounds(point: toboggan.position) {
            if map.hasTree(at: toboggan.position) {
                numTrees += 1
            }
            toboggan.move()
        }
        
        print("Trees: \(numTrees)")
    }
}

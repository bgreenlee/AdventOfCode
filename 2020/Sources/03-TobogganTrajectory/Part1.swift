struct Part1 {
    static func run(map: Map) {
        var toboggan = Toboggan(slope: Slope(right: 3, down: 1))
        let numTrees = toboggan.run(on: map)
        print("Trees: \(numTrees)")
    }
}

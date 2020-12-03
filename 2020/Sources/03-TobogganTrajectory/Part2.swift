struct Part2 {
    static func run(map: Map) {
        let slopes = [
            Slope(right: 1, down: 1),
            Slope(right: 3, down: 1),
            Slope(right: 5, down: 1),
            Slope(right: 7, down: 1),
            Slope(right: 1, down: 2),
        ]
        let treeCounts: [Int] = slopes.map {
            var toboggan = Toboggan(slope: $0)
            return toboggan.run(on: map)
        }
        let product = treeCounts.reduce(1, { $0 * $1 })
        print("Product: \(product)")
    }
}

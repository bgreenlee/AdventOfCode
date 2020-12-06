struct Part1 {
    static func run(with lines:[String]) {
        var groups:[Set<Character>] = []
        var currentGroup:Set<Character> = []

        // lazily assumes a blank line at the end
        for line in lines {
            if line == "" {
                groups.append(currentGroup)
                currentGroup = []
                continue
            }
            currentGroup.formUnion(line)
        }

        let sum = groups.map { $0.count }.reduce(0, +)
        print("Part 1: \(sum)")
    }
}

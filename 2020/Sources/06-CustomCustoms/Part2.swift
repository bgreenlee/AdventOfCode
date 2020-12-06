struct Part2 {
    static func run(with lines:[String]) {
        var groups:[Set<Character>] = []
        var currentGroup:[Set<Character>] = []

        // assumes a blank line at the end
        for line in lines {
            if line == "" {
                let common = currentGroup.reduce(Set(currentGroup.first!)) { (acc, list) in acc.intersection(list) }
                groups.append(common)
                currentGroup = []
            } else {
                currentGroup.append(Set(line))
            }
        }

        let sum = groups.map { $0.count }.reduce(0, +)
        print("Part 2: \(sum)")
    }
}

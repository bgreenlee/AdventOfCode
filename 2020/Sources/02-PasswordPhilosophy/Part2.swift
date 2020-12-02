struct Part2 {
    static func run(with input: [String]) {
        var numGood = 0
        for line in input {
            let lineParts = line.components(separatedBy: ": ")
            if lineParts.count != 2 {
                continue
            }
            let policy = lineParts[0]
            let password = lineParts[1]
            
            let policyParts = policy.components(separatedBy: " ")
            let positions = policyParts[0]
                                .components(separatedBy: "-")
                                .map { Int($0) ?? 0 }
                                .filter { $0 > 0 }
            let character = Character(policyParts[1])
                        
            if positions.filter({ $0 <= password.count && password[$0 - 1] == character }).count == 1 {
                numGood += 1
            }
        }
        print("Number of good passwords: \(numGood)")
    }
}

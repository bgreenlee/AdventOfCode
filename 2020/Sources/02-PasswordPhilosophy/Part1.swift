struct Part1 {
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
            let range = policyParts[0]
            let character = Character(policyParts[1])
            
            let rangeParts = range.components(separatedBy: "-")
            let minRange = Int(rangeParts[0]) ?? 0
            let maxRange = Int(rangeParts[1]) ?? 0
            
            let characterCount = password.filter { $0 == character }.count
            if characterCount >= minRange && characterCount <= maxRange {
                numGood += 1
            }
        }
        print("Number of good passwords: \(numGood)")
    }
}

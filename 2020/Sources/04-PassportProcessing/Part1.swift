import Foundation

struct Part1 {
    static func run(with records: [String]) {
        // match valid fields in each line
        let validFieldsRegex = try! NSRegularExpression(pattern: "(byr|iyr|eyr|hgt|hcl|ecl|pid):")
        var numValid = 0
        for record in records {
            let numMatches = validFieldsRegex.numberOfMatches(in: record, options: [], range: NSRange(location: 0, length: record.count))
            if numMatches == 7 {
                numValid += 1
            }
        }
        print("Valid: \(numValid)")
    }
}

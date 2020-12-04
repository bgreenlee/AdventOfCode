import Foundation

struct Part1 {
    static func run(with records: [String]) {
        // match valid fields in each line
        let validFieldsRegex = try! NSRegularExpression(pattern: "(byr|iyr|eyr|hgt|hcl|ecl|pid):")
        let numValid = records.filter {
            validFieldsRegex.numberOfMatches(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) == 7
        }.count
        print("Valid: \(numValid)")
    }
}

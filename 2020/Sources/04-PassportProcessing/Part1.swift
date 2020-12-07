import Foundation
import Shared

struct Part1 {
    static func run(with records: [String]) {
        // match valid fields in each line
        let validFieldsRegex = try! RegEx(pattern: "(byr|iyr|eyr|hgt|hcl|ecl|pid):")
        let numValid = records.filter {
            validFieldsRegex.matchGroups(in: $0).count == 7
        }.count
        print("Valid: \(numValid)")
    }
}

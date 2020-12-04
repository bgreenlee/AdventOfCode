import Foundation

struct Part2 {
    static func run(with records: [String]) {
        // match valid fields in each line
        let fieldsRegex = try! RegEx(pattern: "(byr|iyr|eyr|hgt|hcl|ecl|pid):(\\S+)")
        var validRecords = 0
        for record in records {
            let matches = fieldsRegex.matchGroups(in: record)
            var validFields = 0
            for match in matches {
                let code = match[0]
                let value = match[1]
                switch code {
                case "byr":
                    if value.count == 4 {
                        let year = Int(value) ?? 0
                        if year >= 1920 && year <= 2002 {
                            validFields += 1
                        }
                    }
                case "iyr":
                    if value.count == 4 {
                        let year = Int(value) ?? 0
                        if year >= 2010 && year <= 2020 {
                            validFields += 1
                        }
                    }
                case "eyr":
                    if value.count == 4 {
                        let year = Int(value) ?? 0
                        if year >= 2020 && year <= 2030 {
                            validFields += 1
                        }
                    }
                case "hgt":
                    let validRegex = try! RegEx(pattern: "^(\\d+)(cm|in)$")
                    let hgtMatch = validRegex.matchGroups(in: value)
                    if hgtMatch.count == 1 {
                        let height = Int(hgtMatch.first![0]) ?? 0
                        let unit = hgtMatch.first![1]
                        if unit == "cm" && height >= 150 && height <= 193 {
                            validFields += 1
                        } else if unit == "in" && height >= 59 && height <= 76 {
                            validFields += 1
                        }
                    }
                case "hcl":
                    let validRegex = try! RegEx(pattern: "^#[0-9a-f]{6}$")
                    if validRegex.matchGroups(in: value).count == 1 {
                        validFields += 1
                    }
                case "ecl":
                    let validRegex = try! RegEx(pattern: "^amb|blu|brn|gry|grn|hzl|oth$")
                    if validRegex.matchGroups(in: value).count == 1 {
                        validFields += 1
                    }
                case "pid":
                    let validRegex = try! RegEx(pattern: "^\\d{9}$")
                    if validRegex.matchGroups(in: value).count == 1 {
                        validFields += 1
                    }
                default:
                    break // ignore anything else
                }
            }
            if validFields == 7 {
                validRecords += 1
            }
        }
        print("Valid: \(validRecords)")
    }
}

import Foundation

struct Part2 {
    static func run(with records: [String]) {
        // match valid fields in each line
        let fieldsRegex = try! NSRegularExpression(pattern: "(byr|iyr|eyr|hgt|hcl|ecl|pid):(\\S+)")
        var validRecords = 0
        for record in records {
            let matches = fieldsRegex.matches(in: record, options: [], range: NSRange(location: 0, length: record.count))
            var validFields = 0
            for match in matches {
                let code = record[Range(match.range(at: 1), in:record)!] // yuck, Swift
                let value = String(record[Range(match.range(at: 2), in:record)!])
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
                    let validRegex = try! NSRegularExpression(pattern: "^(\\d+)(cm|in)$")
                    if let hgtMatch = validRegex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) {
                        let height = Int(value[Range(hgtMatch.range(at: 1), in:value)!]) ?? 0
                        let unit = value[Range(hgtMatch.range(at: 2), in:value)!]
                        if unit == "cm" && height >= 150 && height <= 193 {
                            validFields += 1
                        } else if unit == "in" && height >= 59 && height <= 76 {
                            validFields += 1
                        }
                    }
                case "hcl":
                    let validRegex = try! NSRegularExpression(pattern: "^#[0-9a-f]{6}$")
                    if validRegex.numberOfMatches(in: value, options: [], range: NSRange(location: 0, length: value.count)) == 1 {
                        validFields += 1
                    }
                case "ecl":
                    let validRegex = try! NSRegularExpression(pattern: "^amb|blu|brn|gry|grn|hzl|oth$")
                    if validRegex.numberOfMatches(in: value, options: [], range: NSRange(location: 0, length: value.count)) == 1 {
                        validFields += 1
                    }
                case "pid":
                    let validRegex = try! NSRegularExpression(pattern: "^\\d{9}$")
                    if validRegex.numberOfMatches(in: value, options: [], range: NSRange(location: 0, length: value.count)) == 1 {
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

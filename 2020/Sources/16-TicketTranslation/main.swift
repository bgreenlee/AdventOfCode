import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    // read fields & ranges
    var fieldRanges:Dictionary<String, [ClosedRange<Int>]> = [:]
    var i = 0
    while rows[i] != "your ticket:" {
        let mainParts = rows[i].components(separatedBy: ": ")
        let field = mainParts[0]
        let rangeStrings = mainParts[1].components(separatedBy: " or ")
        var ranges:[ClosedRange<Int>] = []
        for rangeString in rangeStrings {
            let numbers = rangeString.components(separatedBy: "-").map { Int($0)! }
            ranges.append(numbers[0]...numbers[1])
        }
        fieldRanges[field] = ranges
        i += 1
    }

    let myTicket = rows[i+1].components(separatedBy: ",").map { Int($0)! }

    var nearbyTickets:[[Int]] = []
    for j in i+3..<rows.count {
        let ticket = rows[j].components(separatedBy: ",").map { Int($0)! }
        nearbyTickets.append(ticket)
    }

    let allRanges = fieldRanges.values.reduce([], +)

    let isInvalid = {num in allRanges.allSatisfy({!$0.contains(num)})}
    let invalid = nearbyTickets.flatMap({$0}).filter(isInvalid)
    let errorRate = invalid.reduce(0, +)
    print("Part 1: \(errorRate)")

    // Part 2
    let validTickets = nearbyTickets.filter({$0.filter(isInvalid).count == 0})
    var colsFields:Dictionary<Int, Set<String>> = [:]
    for col in 0..<validTickets[0].count {
        let values = validTickets.map { $0[col] }
        var validFields: Set<String> = Set(fieldRanges.keys)
        for (field, ranges) in fieldRanges {
            for value in values {
                if ranges.allSatisfy({ !$0.contains(value) }) {
                    validFields.remove(field) // value not valid for this field
                    break
                }
            }
        }
        colsFields[col] = validFields
    }

    var fieldMap:Dictionary<String, Int> = [:]
    while colsFields.flatMap({_, v in v}).count > colsFields.count {
        for (col, fields) in colsFields {
            colsFields[col] = fields.subtracting(fieldMap.keys)
            if colsFields[col]?.count == 1 {
                fieldMap[Array(colsFields[col]!)[0]] = col
            }
        }
    }

    let departureCols = fieldMap.filter({k,v in k.starts(with: "departure")}).values
    let answer = departureCols.reduce(1, { a, col in a * myTicket[col] })
    print("Part 2: \(answer)")
}

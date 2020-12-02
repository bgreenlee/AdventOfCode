import Foundation

// read the numbers into a Set
var numbers: Set<Int> = []
if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat") {
    let data = try String(contentsOf: inputURL)
    let numstrs = data.components(separatedBy: .newlines)
    for numstr in numstrs {
        if let num = Int(numstr) {
            numbers.update(with: num)
        }
    }
}

print("Part 1:")
Part1.run(expenseReport: ExpenseReport(target: 2020, numbers: numbers))

print("Part 2:")
Part2.run(expenseReport: ExpenseReport(target: 2020, numbers: numbers))

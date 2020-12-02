struct Part2 {
    static func run(expenseReport: ExpenseReport) {
        for number in expenseReport.numbers {
            let diff = expenseReport.target - number
            if let (a,b) = expenseReport.findNumbers(summingTo: diff) {
                print("\(number) * \(a) * \(b) = \(number * a * b)")
                break
            }
        }
    }
}

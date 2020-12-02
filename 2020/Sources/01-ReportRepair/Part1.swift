struct Part1 {
    static func run(expenseReport: ExpenseReport) {
        if let (a,b) = expenseReport.findNumbers(summingTo: expenseReport.target) {
            print("\(a) * \(b) = \(a * b)")
        }
    }
}

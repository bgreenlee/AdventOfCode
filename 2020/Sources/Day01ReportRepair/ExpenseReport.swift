struct ExpenseReport {
    var target: Int
    var numbers: Set<Int>
        
    init(target: Int, numbers: Set<Int>) {
        self.target = target
        self.numbers = numbers
    }

    func findNumbers(summingTo target: Int) -> (Int, Int)? {
        for number in numbers {
            let diff = target - number
            if numbers.contains(diff) {
                return (number, diff)
            }
        }
        return nil
    }
}

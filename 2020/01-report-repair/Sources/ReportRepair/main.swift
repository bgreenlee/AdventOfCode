let target = 2020
var numbers: Set<Int> = []

while let line = readLine(strippingNewline: true) {
    numbers.update(with: Int(line) ?? 0)
}

func findNumbers(in numbers: Set<Int>, summingTo target: Int) -> (Int, Int)? {
    for number in numbers {
        let diff = target - number
        if numbers.contains(diff) {
            return (number, diff)
        }
    }
    return nil
}

// Part 1
if let (a,b) = findNumbers(in: numbers, summingTo: target) {
    print("\(a) * \(b) = \(a * b)")
}

// Part 2
for number in numbers {
    let diff = target - number
    if let (a,b) = findNumbers(in: numbers, summingTo: diff) {
        print("\(number) * \(a) * \(b) = \(number * a * b)")
        break
    }
}

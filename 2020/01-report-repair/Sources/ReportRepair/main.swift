let target = 2020
var numbers: Set<Int> = []

while let line = readLine(strippingNewline: true) {
    numbers.update(with: Int(line) ?? 0)
}

for number in numbers {
    let diff = target - number
    if numbers.contains(diff) {
        print("\(number) * \(diff) = \(number * diff)\n")
        break
    }
}

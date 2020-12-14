import Foundation
import Shared
import BigInt

if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 1 }
    let target = Int(rows[0]) ?? 0
    let busses = rows[1].components(separatedBy: ",")
        .map { Int($0) ?? 0 }

    // Part 1
    var targetBus = 0
    var minTime = Int.max
    for bus in busses.filter({ $0 > 0 }) {
        let time = (target / bus + 1) * bus - target
        if time < minTime {
            minTime = time
            targetBus = bus
        }
    }
    print("Part 1: \(targetBus * minTime)")

    // Part 2

    // generate congruences
    var congruences: Array<(BigInt, BigInt)> = []
    for (i, bus) in busses.enumerated() {
        if bus > 0 {
            congruences.append((BigInt((bus-i)%bus), BigInt(bus)))
        }
    }

    // calculate using the Chinese Remainder Theorem
    while congruences.count > 1 {
        let (a1, n1) = congruences.popLast()!
        let (a2, n2) = congruences.popLast()!
        let (_, m1, _) = xgcd(n2, n1)
        let (_, m2, _) = xgcd(n1, n2)
        var x = a1*m1*n2 + a2*m2*n1
        if x < 0 {
            x += (abs(x)/(n1*n2) + 1) * n1*n2 // make it positive
        }
        congruences.append((x, n1*n2))
    }
    let (x, _) = congruences[0]
    print("Part 2: \(x)")
}

// Extended Euclidean Algorithm
// Return (g, x, y) such that ax + by = g = gcd(a, b)
func xgcd(_ a: BigInt, _ b: BigInt) -> (BigInt, BigInt, BigInt) {
    var (x0, x1) = (BigInt(0), BigInt(1))
    var (y0, y1) = (BigInt(1), BigInt(0))
    var (a, b) = (a, b)
    var q: BigInt

    while a != 0 {
        ((q, a), b) = (b.quotientAndRemainder(dividingBy: a), a)
        (y0, y1) = (y1, y0 - q * y1)
        (x0, x1) = (x1, x0 - q * x1)
    }
    return (b, x0, y0)
}

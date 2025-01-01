//
//  MonkeyMarket.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/31/24.
//

class MonkeyMarket: Solution {
    init() {
        super.init(id: 22, name: "Monkey Market", hasDisplay: true)
    }

    func nextSecret(_ num: Int) -> Int {
        var newnum = num ^ (num * 64)
        newnum %= 16777216
        newnum ^= newnum / 32
        newnum %= 16777216
        newnum ^= newnum * 2048
        newnum %= 16777216
        return newnum
    }

    override func part1(_ input: [String]) -> String {
        let secrets = input.map { Int($0)! }
        var sum: Int = 0
        for var secret in secrets {
            for _ in 1...2000 {
                secret = nextSecret(secret)
            }
            sum += secret
        }
        return String(sum)
    }

    override func part2(_ input: [String]) -> String {
        let secrets = input.map { Int($0)! }
        var allChanges: [SIMD4<Int>:Int] = [:]
        for var secret in secrets {
            var prices: [Int] = [secret % 10]
            for _ in 1...2000 {
                secret = nextSecret(secret)
                prices.append(secret % 10)
            }
            var changes: [Int] = []
            for i in 1..<prices.count {
                changes.append(prices[i] - prices[i - 1])
            }
            var seenSeries: Set<SIMD4<Int>> = []
            for i in 3..<changes.count {
                let series = SIMD4(changes[i-3], changes[i-2], changes[i-1], changes[i])
                if seenSeries.contains(series) {
                    continue
                }
                seenSeries.insert(series)
                allChanges[series, default: 0] += prices[i+1]
            }
        }
        let best = allChanges.max(by: { a, b in
            return a.value < b.value
        })!
        return String(best.value)
    }
}

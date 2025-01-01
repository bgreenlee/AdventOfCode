//
//  LANParty.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/31/24.
//

class LANParty: Solution {
    init() {
        super.init(id: 23, name: "LAN Party", hasDisplay: true)
    }

    override func part1(_ input: [String]) -> String {
        var connections: [String:[String]] = [:]
        for line in input {
            let pair = line.split(separator: "-")
            let a = String(pair[0])
            let b = String(pair[1])
            connections[a, default: []].append(b)
            connections[b, default: []].append(a)
        }
        let tcons = connections.filter { $0.key.starts(with: "t")}
        var triplets: Set<[String]> = []
        for (a, value) in tcons {
            for i in 0..<value.count-1 {
                for j in i+1..<value.count {
                    let b = value[i]
                    let c = value[j]
                    if connections[b, default: []].contains(c) && connections[c, default: []].contains(a) {
                        triplets.insert([a, b, c].sorted())
                    }
                }
            }
        }
        return String(triplets.count)
    }

    override func part2(_ input: [String]) -> String {
        var connections: [String:Set<String>] = [:]
        for line in input {
            let pair = line.split(separator: "-")
            let a = String(pair[0])
            let b = String(pair[1])
            connections[a, default: Set([a])].insert(b)
            connections[b, default: Set([b])].insert(a)
        }
        var allIntersections: [Set<String>:Int] = [:]
        for (key, conns) in connections {
            let maxIntersection = conns
                .filter({ $0 != key })
                .map({ connections[$0, default: Set()].intersection(conns) })
                .max(by: { $0.count < $1.count })!
            allIntersections[maxIntersection, default: 0] += 1
        }
        let maxAllIntersections = allIntersections.max(by: { a, b in a.value < b.value })!
        let password = Array(maxAllIntersections.key).sorted().joined(separator: ",")
        return password
    }
}

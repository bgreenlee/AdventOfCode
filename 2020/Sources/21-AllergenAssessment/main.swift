import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let re = try! RegEx(pattern: #"^([\w\s]+) \(contains (.*?)\)$"#)
    var allergenMap:Dictionary<String, Set<String>> = [:]
    var allFoods:Dictionary<String, Int> = [:]

    for line in lines {
        let matches = re.matchGroups(in: line)

        let foods = matches[0][0].components(separatedBy: " ")
        for food in foods {
            allFoods[food, default: 0] += 1
        }

        let allergens = matches[0][1].components(separatedBy: ", ")
        for allergen in allergens {
            if allergenMap[allergen] == nil {
                allergenMap[allergen] = Set(foods)
            } else {
                allergenMap[allergen]!.formIntersection(Set(foods))
            }
        }
    }

    let allergenFoods = Set(allergenMap.values.flatMap({$0}))
    let noAllergenFoods = Set(allFoods.keys).subtracting(allergenFoods)
    let sum = noAllergenFoods.map({ allFoods[$0]! }).reduce(0,+)
    print("Part 1: \(sum)")

    var assignedFoods:Set<String> = []
    while allergenMap.values.flatMap({$0}).count > allergenMap.keys.count {
        for (allergen, foods) in allergenMap {
            if foods.count == 1 {
                assignedFoods.formUnion(foods)
            } else {
                allergenMap[allergen] = allergenMap[allergen]?.subtracting(assignedFoods)
            }
        }
    }
    var output:[String] = []
    for allergen in allergenMap.keys.sorted() {
        output.append(allergenMap[allergen]!.first!)
    }
    print("Part 2: \(output.joined(separator: ","))")

}

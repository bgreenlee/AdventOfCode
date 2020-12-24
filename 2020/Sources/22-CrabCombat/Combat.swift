import Foundation

struct Combat {
    var playerCards:Dictionary<Int,[Int]> = [:]

    init(_ input:[String]) {
        var playerNum = 0
        for line in input {
            if line.starts(with: "Player") {
                playerNum += 1
            } else {
                playerCards[playerNum, default:[]].append(Int(line)!)
            }
        }
    }

    func calculateScore(_ player1:[Int], _ player2:[Int]) -> Int {
        var score = 0
        for (i, num) in (player1 + player2).reversed().enumerated() {
            score += num * (i+1)
        }
        return score
    }

    // Non-recursive (Part 1) game
    func play() -> Int {
        var player1 = playerCards[1]!
        var player2 = playerCards[2]!
        while !player1.isEmpty && !player2.isEmpty {
            let card1 = player1.removeFirst()
            let card2 = player2.removeFirst()
            if card1 > card2 {
                player1.append(contentsOf: [card1, card2])
            } else {
                player2.append(contentsOf: [card2, card1])
            }
        }

        return calculateScore(player1, player2)
    }

    // Recursive (Part 2) game
    func playRecursive() -> Int {
        let (_, score) = playGame(playerCards[1]!, playerCards[2]!)
        return score
    }

    // play a [sub-]game with the given decks
    // return a tuple of (winner number, score)
    func playGame(_ player1:[Int], _ player2:[Int]) -> (Int, Int) {
        var (p1, p2) = (player1, player2)
        var previous:Set<[[Int]]> = []

//        print("New [sub-]game:")
//        print("Player 1: \(p1)")
//        print("Player 2: \(p2)")

        while !p1.isEmpty && !p2.isEmpty {
            // if we've seen this configuration before, player 1 wins
            let (inserted, _) = previous.insert([p1, p2])
            if !inserted {
//                print("We've seen this before, player 1 wins!")
                return (1, calculateScore(p1, p2))
            }

            let card1 = p1.removeFirst()
            let card2 = p2.removeFirst()

            if card1 <= p1.count && card2 <= p2.count {
                // play subgame
                let (winner, _) = playGame(Array(p1[..<card1]), Array(p2[..<card2]))
             //   print("player \(winner) wins!")
                if winner == 1 {
                    p1.append(contentsOf: [card1, card2])
                } else {
                    p2.append(contentsOf: [card2, card1])
                }
            } else if card1 > card2 {
                p1.append(contentsOf: [card1, card2])
            } else {
                p2.append(contentsOf: [card2, card1])
            }
        }
        return (p2.isEmpty ? 1 : 2, calculateScore(p1, p2))
    }
}

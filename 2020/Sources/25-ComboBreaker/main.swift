import Foundation
import Shared

// test
//let cardPublicKey = 5764801
//let doorPublicKey = 17807724

// prod
let cardPublicKey = 5290733
let doorPublicKey = 15231938

func transform(value: Int, subjectNum: Int) -> Int {
    return (value * subjectNum) % 20201227
}

func loopSize(publicKey: Int, subjectNum: Int = 7) -> Int {
    var value = 1
    var loopSize = 0
    while value != publicKey {
        value = transform(value: value, subjectNum: subjectNum)
        loopSize += 1
    }

    return loopSize
}

func encryptionKey(publicKey: Int, loopSize: Int) -> Int {
    var value = 1
    for _ in 1...loopSize {
        value = transform(value: value, subjectNum: publicKey)
    }
    return value
}

var encKey = 0
let cardLoopSize = loopSize(publicKey: cardPublicKey)
// let doorLoopSize = loopSize(publicKey: doorPublicKey)
encKey = encryptionKey(publicKey: doorPublicKey, loopSize: cardLoopSize)
print("encryption key: \(encKey)")

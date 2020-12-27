extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

//public extension StringProtocol {
//    subscript(offset: Int) -> Character {
//        self[index(startIndex, offsetBy: offset)]
//    }
//
//    subscript(range: Range<Int>) -> SubSequence {
//        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
//        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
//    }
//
//    subscript(range: ClosedRange<Int>) -> SubSequence {
//        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
//        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
//    }
//
//    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
//        self[index(startIndex, offsetBy: range.lowerBound)...]
//    }
//
//    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
//        self[...index(startIndex, offsetBy: range.upperBound)]
//    }
//
//    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
//        self[..<index(startIndex, offsetBy: range.upperBound)]
//    }
//    
//    func replaceCharacter(at index: Int, with newChar: Character) -> String {
//        var chars = Array(self)
//        chars[index] = newChar
//        let modifiedString = String(chars)
//        return modifiedString
//    }
//}



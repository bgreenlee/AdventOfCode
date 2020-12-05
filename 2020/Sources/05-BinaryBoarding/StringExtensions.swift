extension StringProtocol {
    // make indexing into Strings less annoying
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    
//    subscript(range: Range)
}


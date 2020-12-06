extension StringProtocol {
    // make indexing into Strings less annoying
    public subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}


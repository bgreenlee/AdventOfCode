struct BoardingPass: Comparable, CustomStringConvertible {
    let code: String
    let id: Int
    
    var description: String {
        return "\(code) (\(id))"
    }
    
    init?(_ code: String) {
        self.code = code

        let binary = code
            .replacingOccurrences(of: "F", with: "0")
            .replacingOccurrences(of: "B", with: "1")
            .replacingOccurrences(of: "L", with: "0")
            .replacingOccurrences(of: "R", with: "1")

        if let id = Int(binary, radix: 2) {
            self.id = id
        } else {
            return nil
        }
    }
    
    // comparison functions for Comparable
    static func < (lhs: BoardingPass, rhs: BoardingPass) -> Bool {
        lhs.id < rhs.id
    }
    
    static func == (lhs: BoardingPass, rhs: BoardingPass) -> Bool {
        lhs.id == rhs.id
    }
    
}

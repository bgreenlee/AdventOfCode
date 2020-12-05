struct BoardingPass {
    let code: String
    let id: Int

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
}

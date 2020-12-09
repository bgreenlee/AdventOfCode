extension Collection where Element: Numeric {
    public func sum() -> Element? {
        if self.isEmpty {
            return nil
        }
        return self.reduce(0, +)
    }
}

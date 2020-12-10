import Foundation

extension Decimal {
    public var int: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}

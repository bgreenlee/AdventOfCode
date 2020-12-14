import Foundation

extension Decimal {
    public var int: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
    
    public var uint: UInt {
        return NSDecimalNumber(decimal: self).uintValue
    }
}

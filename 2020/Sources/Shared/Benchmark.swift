import Foundation

public func time(code:()->()) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    code()
    return CFAbsoluteTimeGetCurrent() - start
}

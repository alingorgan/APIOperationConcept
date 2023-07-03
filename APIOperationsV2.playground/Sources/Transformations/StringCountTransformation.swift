import Foundation

public struct StringCountTransformation: Transformation {
    public init() { }
    
    public func transform(_ input: String) -> Int {
        input.count
    }
}

import Foundation

public struct StubErrorTransformation: Transformation {
    let stubError: Error
    
    public init(stubError: Error) {
        self.stubError = stubError
    }
    
    public func transform(_ input: Error) -> Error {
        stubError
    }
}

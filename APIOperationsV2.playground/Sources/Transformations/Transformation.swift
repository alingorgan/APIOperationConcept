import Foundation

/**
 A reusable component which transforms a given input of `Input` type into the expected `Output` type
 */
public protocol Transformation {
    associatedtype Input
    associatedtype Output

    /**
     Transforms the provided input into the expected output type
     - Parameter input: The provided input to tranform
     - Returns: The transformed `input` of `Output` type
     */
    func transform(_ input: Input) -> Output
}

/**
 A type erased `Transformation` which hides the concrete `Transformation` type clients.
 */
public struct AnyTransformation<Input, Output>: Transformation {
    let wrappedTransform: (Input) -> Output

    public init(_ wrappedTransform: @escaping (Input) -> Output) {
        self.wrappedTransform = wrappedTransform
    }

    /**
     Transforms the provided input into the expected output type
     - Parameter input: The provided input to tranform
     - Returns: The transformed `input` of `Output` type
     */
    public func transform(_ input: Input) -> Output {
        wrappedTransform(input)
    }
}

extension Transformation {
    /**
     Type erases a concrete `Transformation`
     */
    public func toAny() -> AnyTransformation<Input, Output> {
        .init(transform)
    }
}

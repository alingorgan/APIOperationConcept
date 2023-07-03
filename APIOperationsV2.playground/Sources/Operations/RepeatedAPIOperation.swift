import Foundation

struct RepeatedAPIOperation<Output: RawModel>: APIOperation {
    let operation: AnyOperation<Output>
    let seconds: TimeInterval

    func perform(completion: (Result<Output, Error>) -> Void) -> Cancellable {
        operation.perform(completion: completion)
        // TODO: make a timer that fires and calls perform
        return self
    }

    func cancel() {
        operation.cancel()
    }
}

extension AnyOperation {
    public func every(seconds: TimeInterval) -> AnyOperation<Output> {
        RepeatedAPIOperation(
            operation: self,
            seconds: seconds)
        .eraseToAnyOperation()
    }
}

import Foundation

/**
 Defines an API operation which is executed at specific time intervals
 */
struct RepeatedAPIOperation<Output: RawModel>: APIOperation {
    let operation: AnyAPIOperation<Output>
    let seconds: TimeInterval

    func perform(completion: (Result<Output, Error>) -> Void) -> CancellableOperation {
        // TODO: make a timer that fires and calls perform
        let cancellable = operation.perform(completion: completion)
        return AnyCancellable(cancelOperations: [cancellable.cancelOperation, cancel])
    }
    
    func cancel() {
        // TODO: Stop timers and cleanup
    }
}

extension AnyAPIOperation {
    public func every(seconds: TimeInterval) -> AnyAPIOperation<Output> {
        RepeatedAPIOperation(
            operation: self,
            seconds: seconds)
        .eraseToAnyOperation()
    }
}

import Foundation

/**
 Defines an API operation which retries, on error.
 */
final class RetryAPIOperation<Output: RawModel>: APIOperation {
    private var maxRetryCount: UInt
    private let operation: AnyAPIOperation<Output>

    init(operation: AnyAPIOperation<Output>, maxRetryCount: UInt) {
        self.operation = operation
        self.maxRetryCount = maxRetryCount
    }

    @discardableResult
    func perform(completion: (Result<Output, Error>) -> Void) -> CancellableOperation {
        operation.perform { [weak self] result in
            guard let self,
                  case .failure = result,
                  maxRetryCount > 0
            else {
                completion(result)
                return
            }
            maxRetryCount -= 1
            perform(completion: completion)
        }
    }
}

extension AnyAPIOperation {
    public func retryOnError(count: UInt) -> AnyAPIOperation<Output> {
        RetryAPIOperation(
            operation: self,
            maxRetryCount: count)
        .eraseToAnyOperation()
    }
}

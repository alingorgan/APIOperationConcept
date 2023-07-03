import Foundation

final class RetryAPIOperation<Output: RawModel>: APIOperation {
    private var maxRetryCount: UInt
    private let operation: AnyOperation<Output>

    init(operation: AnyOperation<Output>, maxRetryCount: UInt) {
        self.operation = operation
        self.maxRetryCount = maxRetryCount
    }

    @discardableResult
    func perform(completion: (Result<Output, Error>) -> Void) -> Cancellable {
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
        return self
    }

    func cancel() {
        operation.cancel()
    }
}

extension AnyOperation {
    public func retryOnError(count: UInt) -> AnyOperation<Output> {
        RetryAPIOperation(
            operation: self,
            maxRetryCount: count)
        .eraseToAnyOperation()
    }
}

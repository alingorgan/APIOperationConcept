import Foundation

final class CachedOperation<Output: RawModel>: APIOperation {

    private var cachedValue: Result<Output, Error>? {
        didSet {
            // TODO: start a timer and nullify the cached value when it fires
        }
    }
    let operation: AnyOperation<Output>
    let cacheTimeout: TimeInterval

    init(operation: AnyOperation<Output>, cacheTimeout: TimeInterval) {
        self.operation = operation
        self.cacheTimeout = cacheTimeout
    }

    func perform(completion: (Result<Output, Error>) -> Void) -> Cancellable {
        if let cachedValue {
            completion(cachedValue)
            return self
        }
        operation.perform { result in
            cachedValue = result
            completion(result)
        }
        return self
    }

    func cancel() {
        operation.cancel()
    }
}

extension AnyOperation {
    public func cached(timeout: TimeInterval) -> AnyOperation<Output> {
        CachedOperation(
            operation: self,
            cacheTimeout: timeout)
        .eraseToAnyOperation()
    }
}

import Foundation

/**
 Defines an API operation with a response cache
 */
final class CachedOperation<Output: RawModel>: APIOperation {

    private var cachedValue: Result<Output, Error>? {
        didSet {
            // TODO: start a timer and nullify the cached value when it fires
        }
    }
    private var cancellable: CancellableOperation?
    let operation: AnyAPIOperation<Output>
    let cacheTimeout: TimeInterval

    init(operation: AnyAPIOperation<Output>, cacheTimeout: TimeInterval) {
        self.operation = operation
        self.cacheTimeout = cacheTimeout
    }

    func perform(completion: (Result<Output, Error>) -> Void) -> CancellableOperation {
        if let cachedValue {
            completion(cachedValue)
            return AnyCancellable()
        }
        return operation.perform { result in
            cachedValue = result
            completion(result)
        }
    }
}

extension AnyAPIOperation {
    public func cached(timeout: TimeInterval) -> AnyAPIOperation<Output> {
        CachedOperation(
            operation: self,
            cacheTimeout: timeout)
        .eraseToAnyOperation()
    }
}

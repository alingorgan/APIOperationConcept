import Foundation

/**
 Defines an API operation which fetches an user ID using a key
 */
final class MockFetchUserIdAPIOperation: APIOperation {
    private var isCancelled = false
    private var key: String

    public init(key: String = "") {
        self.key = key
    }

    public func perform(completion: (Result<Int, Error>) -> Void) -> CancellableOperation {
        guard !isCancelled else { return AnyCancellable() }
        completion(.success(key.count))
        return AnyCancellable(cancelOperation: cancel)
    }

    public func cancel() {
        isCancelled = true
    }
}

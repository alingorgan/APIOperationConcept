import Foundation

final class FetchUserIdAPIOperation: APIOperation {
    private var isCancelled = false
    private var key: String

    public init(key: String = "") {
        self.key = key
    }

    public func perform(completion: (Result<Int, Error>) -> Void) -> Cancellable {
        guard !isCancelled else { return self }
        completion(.success(key.count))
        return self
    }

    public func cancel() {
        isCancelled = true
    }
}

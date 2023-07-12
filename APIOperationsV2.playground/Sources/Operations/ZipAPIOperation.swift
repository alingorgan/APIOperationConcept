import Foundation

/**
 Defines an API operation which completes when underlying operations complete.
 */
final class ZipAPIOperation<T: RawModel & DataModel, U: RawModel & DataModel>: APIOperation {
    private let lhsOperation: AnyAPIOperation<T>
    private let rhsOperation: AnyAPIOperation<U>

    private var lhsResult: Result<T, Error>? = nil
    private var rhsResult: Result<U, Error>? = nil

    init(lhsOperation: AnyAPIOperation<T>, rhsOperation: AnyAPIOperation<U>) {
        self.lhsOperation = lhsOperation
        self.rhsOperation = rhsOperation
    }

    func perform(completion: (Result<Pair<T, U>, Error>) -> Void) -> CancellableOperation {
        let lhsCancellable = lhsOperation.perform { [weak self] result in
            guard let self else { return }
            self.lhsResult = result
            self.processResult(completion)
        }
        let rhsCancellable = rhsOperation.perform { [weak self] result in
            guard let self else { return }
            self.rhsResult = result
            self.processResult(completion)
        }
        
        return AnyCancellable(cancelOperations: [
            lhsCancellable.cancelOperation,
            rhsCancellable.cancelOperation
        ])
    }

    private func processResult(_ completion: (Result<Pair<T, U>, Error>) -> Void) {
        guard let lhsResult, let rhsResult else { return }

        switch (lhsResult, rhsResult) {
        case (.failure(let error), _):
            completion(.failure(error))
        case (_, .failure(let error)):
            completion(.failure(error))
        case (.success(let lhsValue), .success(let rhsValue)):
            completion(.success(.init(lhs: lhsValue, rhs: rhsValue)))
        }
    }
}

public func zip<T: RawModel & DataModel, U: RawModel & DataModel>(_ lhs: AnyAPIOperation<T>, _ rhs: AnyAPIOperation<U>) -> AnyAPIOperation<Pair<T, U>> {
    ZipAPIOperation(
        lhsOperation: lhs,
        rhsOperation: rhs)
    .eraseToAnyOperation()
}

public struct Pair<T: RawModel & DataModel, U: RawModel & DataModel>: RawModel & DataModel {
    let lhs: T
    let rhs: U
}

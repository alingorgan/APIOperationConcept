import Foundation

final class ZipAPIOperation<T: RawModel & DataModel, U: RawModel & DataModel>: APIOperation {
    private let lhsOperation: AnyOperation<T>
    private let rhsOperation: AnyOperation<U>

    private var lhsResult: Result<T, Error>? = nil
    private var rhsResult: Result<U, Error>? = nil

    init(lhsOperation: AnyOperation<T>, rhsOperation: AnyOperation<U>) {
        self.lhsOperation = lhsOperation
        self.rhsOperation = rhsOperation
    }

    func perform(completion: (Result<Pair<T, U>, Error>) -> Void) -> Cancellable {
        lhsOperation.perform { [weak self] result in
            guard let self else { return }
            self.lhsResult = result
            self.processResult(completion)
        }
        rhsOperation.perform { [weak self] result in
            guard let self else { return }
            self.rhsResult = result
            self.processResult(completion)
        }
        return self
    }

    func cancel() {
        lhsOperation.cancel()
        rhsOperation.cancel()
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

public func zip<T: RawModel & DataModel, U: RawModel & DataModel>(_ lhs: AnyOperation<T>, _ rhs: AnyOperation<U>) -> AnyOperation<Pair<T, U>> {
    ZipAPIOperation(
        lhsOperation: lhs,
        rhsOperation: rhs)
    .eraseToAnyOperation()
}

public struct Pair<T: RawModel & DataModel, U: RawModel & DataModel>: RawModel & DataModel {
    let lhs: T
    let rhs: U
}

import Foundation

public struct AnyOperation<Output: RawModel>: Cancellable {
    typealias OperationCompletion = (Result<Output, Error>) -> Void
    private let performOperation: (OperationCompletion) -> Cancellable
    private let cancelOperation: () -> Void

    init(performOperation: @escaping (OperationCompletion) -> Cancellable, cancelOperation: @escaping () -> Void) {
        self.performOperation = performOperation
        self.cancelOperation = cancelOperation
    }

    @discardableResult
    func perform(completion: ((Result<Output, Error>) -> Void) = { _ in }) -> Cancellable {
        _ = performOperation(completion)
        return self
    }

    @discardableResult
    public func perform(transformation: AnyTransformation<Output, DataModel>,
                 completion: ((Result<DataModel, Error>) -> Void) = { _ in }) -> Cancellable {
        perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let rawModel):
                let dataModel = transformation.transform(rawModel)
                completion(.success(dataModel))
            }
        }
        return self
    }

    @discardableResult
    public func perform(completion: ((Result<DataModel & RawModel, Error>) -> Void) = { _ in }) -> Cancellable
    where Output: RawModel, Output: DataModel {
        _ = performOperation { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return self
    }

    public func cancel() {
        cancelOperation()
    }
}

extension APIOperation {
    public func eraseToAnyOperation() -> AnyOperation<Output> {
        AnyOperation(performOperation: perform, cancelOperation: cancel)
    }
}

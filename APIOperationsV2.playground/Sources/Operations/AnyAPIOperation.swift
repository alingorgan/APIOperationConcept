import Foundation

/**
 Defines a type erased API operation
 */
public class AnyAPIOperation<Output: RawModel> {
    typealias OperationCompletion = (Result<Output, Error>) -> Void
    private let performOperation: (OperationCompletion) -> CancellableOperation

    init(performOperation: @escaping (OperationCompletion) -> CancellableOperation) {
        self.performOperation = performOperation
    }

    @discardableResult
    func perform(completion: ((Result<Output, Error>) -> Void) = { _ in }) -> CancellableOperation {
        performOperation(completion)
    }

    @discardableResult
    public func perform(transformation: AnyTransformation<Output, DataModel>,
                 completion: ((Result<DataModel, Error>) -> Void) = { _ in }) -> CancellableOperation {
        perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let rawModel):
                let dataModel = transformation.transform(rawModel)
                completion(.success(dataModel))
            }
        }
    }

    @discardableResult
    public func perform(completion: ((Result<DataModel & RawModel, Error>) -> Void) = { _ in }) -> CancellableOperation
    where Output: RawModel, Output: DataModel {
        performOperation { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension APIOperation {
    public func eraseToAnyOperation() -> AnyAPIOperation<Output> {
        AnyAPIOperation(performOperation: perform)
    }
}

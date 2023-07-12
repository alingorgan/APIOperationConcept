import Foundation

/**
 Defines an API operation which passes the output to another operation as input
 */
final class ValueChainingAPIOperation<TransformedOutput: RawModel, Output: RawModel>: APIOperation {
    let operation: AnyAPIOperation<Output>
    let transformation: AnyTransformation<Output, AnyAPIOperation<TransformedOutput>>
    private var cancellableOperations = [CancellableOperation]()
    private var subsequentOperation: CancellableOperation?

    init(operation: AnyAPIOperation<Output>, transformation: AnyTransformation<Output, AnyAPIOperation<TransformedOutput>>) {
        self.operation = operation
        self.transformation = transformation
    }

    func perform(completion: (Result<TransformedOutput, Error>) -> Void) -> CancellableOperation {
        let cancellable = AnyCancellable()
        let originalOperation = operation.perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                let subsequentOperation = transformation
                    .transform(value)
                    .perform(completion: completion)
                cancellable.add(cancelOperation: subsequentOperation.cancelOperation)
            }
        }
        cancellable.add(cancelOperation: originalOperation.cancelOperation)
        return cancellable
    }
}

extension AnyAPIOperation {
    public func mapValue<T>(_ transformation: AnyTransformation<Output, AnyAPIOperation<T>>) -> AnyAPIOperation<T> {
        ValueChainingAPIOperation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

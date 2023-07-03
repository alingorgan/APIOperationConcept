import Foundation

final class ValueChainingAPIOperation<TransformedOutput: RawModel, Output: RawModel>: APIOperation {
    let operation: AnyOperation<Output>
    let transformation: AnyTransformation<Output, AnyOperation<TransformedOutput>>
    private var subsequentOperation: Cancellable?

    init(operation: AnyOperation<Output>, transformation: AnyTransformation<Output, AnyOperation<TransformedOutput>>) {
        self.operation = operation
        self.transformation = transformation
    }

    func perform(completion: (Result<TransformedOutput, Error>) -> Void) -> Cancellable {
        operation.perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                subsequentOperation = transformation
                    .transform(value)
                    .perform(completion: completion)
            }
        }
        return self
    }

    func cancel() {
        operation.cancel()
        subsequentOperation?.cancel()
    }
}

extension AnyOperation {
    public func mapValue<T>(_ transformation: AnyTransformation<Output, AnyOperation<T>>) -> AnyOperation<T> {
        ValueChainingAPIOperation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

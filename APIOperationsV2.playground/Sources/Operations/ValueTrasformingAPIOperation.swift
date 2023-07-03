import Foundation

struct ValueTrasformingAPIOperation<TransformedOutput: RawModel, Output: RawModel>: APIOperation {
    let operation: AnyOperation<Output>
    let transformation: AnyTransformation<Output, TransformedOutput>

    func perform(completion: (Result<TransformedOutput, Error>) -> Void) -> Cancellable {
        operation.perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                let transformedValue = transformation.transform(value)
                completion(.success(transformedValue))
            }
        }
        return self
    }

    func cancel() {
        operation.cancel()
    }
}

extension AnyOperation {
    public func mapValue<T>(_ transformation: AnyTransformation<Output, T>) -> AnyOperation<T> {
        ValueTrasformingAPIOperation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

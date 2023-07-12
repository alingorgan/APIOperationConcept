import Foundation

/**
 Defines an API operation which transforms the output into another type
 */
struct ValueTrasformingAPIOperation<TransformedOutput: RawModel, Output: RawModel>: APIOperation {
    let operation: AnyAPIOperation<Output>
    let transformation: AnyTransformation<Output, TransformedOutput>

    func perform(completion: (Result<TransformedOutput, Error>) -> Void) -> CancellableOperation {
        operation.perform { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                let transformedValue = transformation.transform(value)
                completion(.success(transformedValue))
            }
        }
    }
}

extension AnyAPIOperation {
    public func mapValue<T>(_ transformation: AnyTransformation<Output, T>) -> AnyAPIOperation<T> {
        ValueTrasformingAPIOperation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

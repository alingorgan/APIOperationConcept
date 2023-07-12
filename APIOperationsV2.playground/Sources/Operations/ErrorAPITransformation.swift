import Foundation

/**
 Defines an API operation which can transform the output error
 */
struct ErrorAPITransformation<Output: RawModel>: APIOperation {
    let operation: AnyAPIOperation<Output>
    let transformation: AnyTransformation<Error, Error>

    func perform(completion: (Result<Output, Error>) -> Void) -> CancellableOperation {
        operation.perform { result in
            guard case .failure(let error) = result else {
                completion(result)
                return
            }
            let transformedError = transformation.transform(error)
            completion(.failure(transformedError))
        }
    }
}

extension AnyAPIOperation {
    public func mapError(_ transformation: AnyTransformation<Error, Error>) -> AnyAPIOperation {
        ErrorAPITransformation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

import Foundation

struct ErrorAPITransformation<Output: RawModel>: APIOperation {
    let operation: AnyOperation<Output>
    let transformation: AnyTransformation<Error, Error>

    func perform(completion: (Result<Output, Error>) -> Void) -> Cancellable {
        operation.perform { result in
            guard case .failure(let error) = result else {
                completion(result)
                return
            }
            let transformedError = transformation.transform(error)
            completion(.failure(transformedError))
        }
        return self
    }

    func cancel() {
        operation.cancel()
    }
}

extension AnyOperation {
    public func mapError(_ transformation: AnyTransformation<Error, Error>) -> AnyOperation {
        ErrorAPITransformation(
            operation: self,
            transformation: transformation)
        .eraseToAnyOperation()
    }
}

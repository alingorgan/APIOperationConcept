import Foundation

/**
    Defines a HTTP operation which is executed using a provided http service
 */
public final class HttpServiceOperation<T: RawModel>: APIOperation {
    let httpService: APIService
    let request: APIRequest
    var isCancelled = false

    public init(request: APIRequest, httpService: APIService) {
        self.request = request
        self.httpService = httpService
    }

    public func perform(completion: (Result<T, Error>) -> Void) -> CancellableOperation {
        guard !isCancelled else {
            return AnyCancellable()
        }
        
        httpService.execute(request) { response in
            guard let data = response.data else {
                completion(.failure(NSError())) // TODO: better error
                return
            }
            completion(data.decode())
        }
        return AnyCancellable(cancelOperation: cancel)
    }

    public func cancel() {
        isCancelled = true
    }
}

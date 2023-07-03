import Foundation

public final class HttpServiceOperation<T: RawModel>: APIOperation {
    let httpService: HTTPService
    let request: Request
    var isCancelled = false

    public init(request: Request, httpService: HTTPService) {
        self.request = request
        self.httpService = httpService
    }

    public func perform(completion: (Result<T, Error>) -> Void) -> Cancellable {
        guard !isCancelled else { return self }
        httpService.execute(MockRequest()) { response in
            guard let data = response.data else {
                completion(.failure(NSError())) // TODO: better error
                return
            }
            completion(data.decode())
        }
        return self
    }

    public func cancel() {
        isCancelled = true
    }
}

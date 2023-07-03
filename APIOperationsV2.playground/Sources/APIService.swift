import Foundation

public protocol Request {

}

public protocol Response {
    var data: Data? { get }
    // ...
}

public protocol HTTPService {
    func execute(_ request: Request, completion: (Response) -> Void)
}

public struct StubHTTPService: HTTPService {
    let stubResponse: Response

    public init(stubResponse: Response) {
        self.stubResponse = stubResponse
    }
    
    public func execute(_ request: Request, completion: (Response) -> Void) {
        // TODO: process request
        // TODO: produce response
        completion(stubResponse)
    }
}

public struct StubResponse: Response {
    public let data: Data?

    public init<T: Encodable>(_ value: T) {
        data = try! JSONEncoder().encode(value)
    }
}

public struct MockRequest: Request {
    public init() {}
}

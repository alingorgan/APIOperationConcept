import Foundation

public struct StubHTTPService: APIService {
    let stubResponse: APIResponse

    public init(stubResponse: APIResponse) {
        self.stubResponse = stubResponse
    }
    
    public func execute(_ request: APIRequest, completion: (APIResponse) -> Void) {
        // TODO: process request
        // TODO: produce response
        completion(stubResponse)
    }
}

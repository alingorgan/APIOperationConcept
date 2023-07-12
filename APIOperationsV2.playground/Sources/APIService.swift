import Foundation

public protocol APIRequest {

}


public protocol APIResponse {
    var data: Data? { get }
    // ...
}

/**
 Defines an API service which executes an APIRequest and completes with a APIResponse
 */
public protocol APIService {
    func execute(_ request: APIRequest, completion: (APIResponse) -> Void)
}

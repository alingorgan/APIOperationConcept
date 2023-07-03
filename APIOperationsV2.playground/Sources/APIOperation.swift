import Foundation

public protocol Cancellable {
    func cancel()
}

public protocol RawModel: Decodable { }
public protocol DataModel: Decodable { }


public protocol APIOperation: Cancellable {
    associatedtype Output: RawModel

    @discardableResult
    func perform(completion: (Result<Output, Error>) -> Void) -> Cancellable
}

extension Int: RawModel, DataModel {}
extension String: RawModel, DataModel {}

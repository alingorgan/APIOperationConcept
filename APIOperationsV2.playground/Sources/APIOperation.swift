import Foundation

public protocol RawModel: Decodable { }
public protocol DataModel: Decodable { }


public protocol APIOperation {
    associatedtype Output: RawModel

    @discardableResult
    func perform(completion: (Result<Output, Error>) -> Void) -> CancellableOperation
}

extension Int: RawModel, DataModel {}
extension String: RawModel, DataModel {}

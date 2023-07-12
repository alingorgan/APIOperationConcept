import Foundation

public struct StubResponse: APIResponse {
    public let data: Data?

    public init<T: Encodable>(_ value: T) {
        data = try? JSONEncoder().encode(value)
    }
}

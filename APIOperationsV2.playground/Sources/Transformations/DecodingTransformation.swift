import Foundation

/**
 Defines a tranfromation which decodes data into an expected type.
 */
struct Decoder<Output: Decodable>: Transformation {
    public var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func transform(_ input: Data) -> Result<Output, Error> {
        do {
            let decoded = try decoder.decode(Output.self, from: input)
            return .success(decoded)
        } catch let error {
            return .failure(error)
        }
    }
}

public extension Data {
    func decode<T: Decodable>() -> Result<T, Error> {
        Decoder().transform(self)
    }
}


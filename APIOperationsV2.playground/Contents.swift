import UIKit

struct APIOperationFactory {
    static func fetchKey() -> AnyAPIOperation<String> {
        HttpServiceOperation(
            request: MockRequest(),
            httpService: StubHTTPService(stubResponse: StubResponse("MyDuMmYkEy")))
        .eraseToAnyOperation()
    }

    static func fetchUserId(key: String = "") -> AnyAPIOperation<Int> {
        HttpServiceOperation(
            request: MockRequest(),
            httpService: StubHTTPService(stubResponse: StubResponse(key.count)))
        .eraseToAnyOperation()
    }
}

let countCharacters = StringCountTransformation().toAny()
let errorTransformation = StubErrorTransformation(
    stubError: NSError(domain: "", code: 0, userInfo: nil))
    .toAny()

run(scenario: "Simple APIOperation usage examples") {
    APIOperationFactory
        .fetchKey()
        .perform { result in
            switch result {
            case .success(let value):
                print("fetchKey operation completed with success: \(value)")
            case .failure(let error):
                print("fetchKey operation completed with error: \(error)")
            }
        }
}

run(scenario: "APIOperation tooling usage examples") {
    APIOperationFactory
        .fetchKey()
        .cached(timeout: 60)
        .every(seconds: 10.0)
        .retryOnError(count: 3)
        .perform { result in
            switch result {
            case .success(let value):
                print("fetchKey operation completed with success: \(value)")
            case .failure(let error):
                print("fetchKey operation completed with error: \(error)")
            }
        }
}


run(scenario: "APIOperation + Transformations = ❤️") {
    APIOperationFactory
        .fetchKey()
        .mapValue(countCharacters)
        .mapError(errorTransformation)
        .perform { result in
            switch result {
            case .success(let value):
                print("fetchKey operation completed with success: \(value)")
            case .failure(let error):
                print("fetchKey operation completed with error: \(error)")
            }
        }
}



run(scenario: "Waiting for multiple operations to finish") {
    let fetchKeyOperation = APIOperationFactory.fetchKey()
    let fetchUserIdOperation = APIOperationFactory.fetchUserId()
    zip(fetchKeyOperation, fetchUserIdOperation)
        .perform { result in
            switch result {
            case .success(let value):
                print("zipped operations completed with: \(value)")
            case .failure(let error):
                print("zipped operations completed with error: \(error)")
            }
        }
}


run(scenario: "Sequenced operations") {
    struct UserIdAPIOperationTransformation: Transformation {
        func transform(_ input: String) -> AnyAPIOperation<Int> {
            print("passed \"\(input)\" to UserIdAPIOperationTransformation")
            return APIOperationFactory.fetchUserId(key: input)
        }
    }
    
    let toUserIdOperation = UserIdAPIOperationTransformation().toAny()
    
    APIOperationFactory
        .fetchKey()
        .mapValue(toUserIdOperation)
        .perform { result in
            switch result {
            case .success(let value):
                print("sequenced operation finished with success: \(value)")
            case .failure(let error):
                print("sequenced operation finished with error: \(error)")
            }
        }
}

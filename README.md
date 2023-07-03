# APIOperation Data Handling Concept

A lightweight, modular, composable and testable business layer, designed for data handling
This is a working concept. Although, some less important stuff are only partially implemented.

## Scenario 1: Simple APIOperation usage examples
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

## Scenario 2: APIOperation tooling usage examples
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


## Scenario 3: APIOperation + Transformations = ❤️
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



## Scenario 4: Waiting for multiple operations to finish
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


## Scenario 5: Sequenced operations
    struct UserIdAPIOperationTransformation: Transformation {
        func transform(_ input: String) -> AnyOperation<Int> {
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


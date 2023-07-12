import Foundation

public protocol CancellableOperation {
    func cancelOperation()
}

final class AnyCancellable: CancellableOperation {
    private(set) var cancelOperations = [() -> Void]()
    
    convenience init(cancelOperation: @escaping () -> Void) {
        self.init(cancelOperations: [cancelOperation])
    }
    
    init(cancelOperations: [() -> Void] = []) {
        self.cancelOperations = cancelOperations
    }
    
    func add(cancelOperation: @escaping () -> Void) {
        cancelOperations.append(cancelOperation)
    }
    
    func cancelOperation() {
        cancelOperations.forEach { $0() }
    }
}

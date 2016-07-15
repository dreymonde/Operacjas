//
//  NoFailedDependencies.swift
//  Operations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public struct NoFailedDependencies: OperationCondition, Fallible {
    
    public enum Error: ErrorType {
        case DependenciesFailed(failed: [(Operation, [ErrorType])])
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        let opers = operation.dependencies.flatMap({ $0 as? Operation })
        let failedOperations = opers.filter {
            if let errors = $0.errors {
                return !errors.isEmpty
            }
            return false
        }
        if !failedOperations.isEmpty {
            let elements = failedOperations.map({ return ($0, $0.errors!) })
            let fail = failed(withError: .DependenciesFailed(failed: elements))
            completion(fail)
        } else {
            completion(.Satisfied)
        }
    }
    
}

internal struct NoFailedDependency: OperationCondition, Fallible {
    
    internal enum Error: ErrorType {
        case DependencyFailed(failed: (Operation, [ErrorType]))
        case DependencyErrorsNil
    }
    
    private var dependency: Operation
    
    internal init(dependency: Operation) {
        self.dependency = dependency
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        guard let errors = dependency.errors else {
            completion(failed(withError: .DependencyErrorsNil))
            return
        }
        if !errors.isEmpty {
            completion(failed(withError: .DependencyFailed(failed: (operation, errors))))
        } else {
            completion(.Satisfied)
        }
    }
    
}

//
//  NoFailedDependencies.swift
//  Operations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public struct NoFailedDependencies: OperationCondition {
    
    public enum Error: ErrorType {
        case DependenciesFailed([(Operation, [ErrorType])])
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        let operations = operation.dependencies.flatMap({ $0 as? Operation })
        let failedOperations = operations.filter({
            if let errors = $0.errors {
                return !errors.isEmpty
            }
            return false
        })
        if !failedOperations.isEmpty {
            let operationsAndErrors = failedOperations.map({ return ($0, $0.errors!) })
            completion(.Failed(with: Error.DependenciesFailed(operationsAndErrors)))
        } else {
            completion(.Satisfied)
        }
    }
    
}

internal struct NoFailedDependency: OperationCondition {
    
    internal enum Error: ErrorType {
        case DependencyFailed((Operation, [ErrorType]))
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
            completion(.Failed(with: Error.DependencyErrorsNil))
            return
        }
        if !errors.isEmpty {
            completion(.Failed(with: Error.DependencyFailed((operation, errors))))
        } else {
            completion(.Satisfied)
        }
    }
    
}

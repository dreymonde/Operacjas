//
//  NoFailedDependencies.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 15.07.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

/**
 A condition that specifies that every dependency must have succeeded without an error.
 If any dependency failed, the target operation will be cancelled.
 
 - Warning: Be careful. This does not apply to cancelled operation as well. If you want
 this kind of behavior, make sure to call `cancelWithError(_:)` instead of just `cancel()`.
 */
public struct NoFailedDependencies: DriftOperationCondition {
    
    public enum ErrorType: Error {
        case dependenciesFailed([(DriftOperation, [Error])])
    }
    
    public init() { }
    
    public func dependencyForOperation(_ operation: DriftOperation) -> Foundation.Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: DriftOperation, completion: (DriftOperationConditionResult) -> Void) {
        let operations = operation.dependencies.flatMap({ $0 as? DriftOperation })
        let failedOperations = operations.filter({
            if let errors = $0.errors {
                return !errors.isEmpty
            }
            return false
        })
        if !failedOperations.isEmpty {
            let operationsAndErrors = failedOperations.map({ return ($0, $0.errors!) })
            completion(.failed(with: ErrorType.dependenciesFailed(operationsAndErrors)))
        } else {
            completion(.satisfied)
        }
    }
    
}

internal struct NoFailedDependency: DriftOperationCondition {
    
    internal enum ErrorType: Error {
        case dependencyFailed((DriftOperation, [Error]))
        case dependencyErrorsNil
    }
    
    private var dependency: DriftOperation
    
    internal init(dependency: DriftOperation) {
        self.dependency = dependency
    }
    
    func dependencyForOperation(_ operation: DriftOperation) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: DriftOperation, completion: (DriftOperationConditionResult) -> Void) {
        guard var errors = dependency.errors else {
            completion(.failed(with: ErrorType.dependencyErrorsNil))
            return
        }
        if let decider = dependency as? ErrorInformer {
            errors = errors.filter({ decider.purpose(of: $0) == .fatal })
            print(errors)
        }
        if !errors.isEmpty {
            completion(.failed(with: ErrorType.dependencyFailed((operation, errors))))
        } else {
            completion(.satisfied)
        }
    }
    
}

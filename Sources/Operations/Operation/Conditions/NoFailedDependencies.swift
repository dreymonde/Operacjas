//
//  NoFailedDependencies.swift
//  Operacjas
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
public struct NoFailedDependencies: OperacjaCondition {
    
    public enum Error: ErrorType {
        case DependenciesFailed([(Operacja, [ErrorType])])
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operacja) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operacja, completion: OperacjaConditionResult -> Void) {
        let operations = operation.dependencies.flatMap({ $0 as? Operacja })
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

internal struct NoFailedDependency: OperacjaCondition {
    
    internal enum Error: ErrorType {
        case DependencyFailed((Operacja, [ErrorType]))
        case DependencyErrorsNil
    }
    
    private var dependency: Operacja
    
    internal init(dependency: Operacja) {
        self.dependency = dependency
    }
    
    func dependencyForOperation(operation: Operacja) -> NSOperation? {
        return nil
    }
    
    func evaluateForOperation(operation: Operacja, completion: OperacjaConditionResult -> Void) {
        guard var errors = dependency.errors else {
            completion(.Failed(with: Error.DependencyErrorsNil))
            return
        }
        if let decider = dependency as? ErrorInformer {
            errors = errors.filter({ decider.purpose(of: $0) == .Fatal })
            print(errors)
        }
        if !errors.isEmpty {
            completion(.Failed(with: Error.DependencyFailed((operation, errors))))
        } else {
            completion(.Satisfied)
        }
    }
    
}

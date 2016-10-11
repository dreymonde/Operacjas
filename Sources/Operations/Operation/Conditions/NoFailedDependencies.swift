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
public struct NoFailedDependencies : OperacjaCondition {
    
    public enum ErrorType : Error {
        case dependenciesFailed([(Operacja, [Error])])
    }
    
    public init() { }
    
    public func dependency(for operation: Operacja) -> Operation? {
        return nil
    }
    
    public func evaluate(for operation: Operacja, completion: (OperacjaConditionResult) -> Void) {
        let operations = operation.dependencies.flatMap({ $0 as? Operacja })
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

internal struct NoFailedDependency : OperacjaCondition {
    
    internal enum ErrorType : Error {
        case dependencyFailed((Operacja, [Error]))
        case dependencyErrorsNil
    }
    
    fileprivate var dependency: Operacja
    
    internal init(dependency: Operacja) {
        self.dependency = dependency
    }
    
    func dependency(for operation: Operacja) -> Operation? {
        return nil
    }
    
    func evaluate(for operation: Operacja, completion: (OperacjaConditionResult) -> Void) {
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

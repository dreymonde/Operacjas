/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was cancelled, the target operation will be cancelled as
    well.
*/
public struct NoCancelledDependencies: OperationCondition {
    
    public enum Error: ErrorType {
        case DependenciesWereCancelled([NSOperation])
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        // Verify that all of the dependencies executed.
        let cancelledDependencies = operation.dependencies.filter({ $0.cancelled })

        if !cancelledDependencies.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            completion(.Failed(with: Error.DependenciesWereCancelled(cancelledDependencies)))
        }
        else {
            completion(.Satisfied)
        }
    }
}

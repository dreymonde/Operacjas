/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the DriftOperationCondition protocol.
*/

import Foundation

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was cancelled, the target operation will be cancelled as
    well.
*/
public struct NoCancelledDependencies: DriftOperationCondition {
    
    public enum ErrorType: Error {
        case dependenciesWereCancelled([Operation])
    }
    
    public init() { }
    
    public func dependencyForOperation(_ operation: DriftOperation) -> Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: DriftOperation, completion: (DriftOperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
        let cancelledDependencies = operation.dependencies.filter({ $0.isCancelled })

        if !cancelledDependencies.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            completion(.failed(with: ErrorType.dependenciesWereCancelled(cancelledDependencies)))
        }
        else {
            completion(.satisfied)
        }
    }
}

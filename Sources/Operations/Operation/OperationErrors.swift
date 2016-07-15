/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

import Foundation

public enum OperationError: ErrorType {
    case ConditionFailed
    case ExecutionFailed
}

public protocol Fallible {
    associatedtype Error: ErrorType
}

extension Fallible where Self: OperationCondition {
    
    func failed(withError error: Error) -> OperationConditionResult {
        return OperationConditionResult.Failed(error: error)
    }
    
}

extension Fallible where Self: Operation {
    
    func finish(withError error: Error) {
        finishWithError(error)
    }
    
}

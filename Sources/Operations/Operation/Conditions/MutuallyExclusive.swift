/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
public struct MutuallyExclusive<T>: OperationCondition {
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    public init() { }

    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        completion(.Satisfied)
    }
}

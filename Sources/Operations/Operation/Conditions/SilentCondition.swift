/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an DriftOperationCondition that composes another DriftOperationCondition.
*/

import Foundation

/**
    A simple condition that causes another condition to not enqueue its dependency.
    This is useful (for example) when you want to verify that you have access to
    the user's location, but you do not want to prompt them for permission if you
    do not already have it.
*/
public struct SilentCondition<T: DriftOperationCondition>: DriftOperationCondition {
    public let condition: T
    
    public static var name: String {
        return "Silent<\(T.name)>"
    }
        
    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(operation: DriftOperation) -> NSOperation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
    public func evaluateForOperation(operation: DriftOperation, completion: DriftOperationConditionResult -> Void) {
        condition.evaluateForOperation(operation, completion: completion)
    }
}

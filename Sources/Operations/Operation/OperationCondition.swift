/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the fundamental logic relating to DriftOperation conditions.
*/

import Foundation

/**
    A protocol for defining conditions that must be satisfied in order for an
    operation to begin execution.
*/
public protocol DriftOperationCondition {
    
    /// The name of the condition
    static var name: String { get }
        
    /**
        Some conditions may have the ability to satisfy the condition if another
        operation is executed first. Use this method to return an operation that
        (for example) asks for permission to perform the operation
        
        - parameter operation: The `DriftOperation` to which the Condition has been added.
        - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
        - note: Only a single operation may be returned as a dependency. If you
            find that you need to return multiple operations, then you should be
            expressing that as multiple conditions. Alternatively, you could return
            a single `GroupOperation` that executes multiple operations internally.
    */
    func dependencyForOperation(_ operation: DriftOperation) -> Operation?
    
    /// Evaluate the condition, to see if it has been satisfied or not.
    func evaluateForOperation(_ operation: DriftOperation, completion: (DriftOperationConditionResult) -> Void)
}

extension DriftOperationCondition {
    public static var name: String {
        return String(Self.self)
    }
}

/**
    An enum to indicate whether an `DriftOperationCondition` was satisfied, or if it
    failed with an error.
*/
public enum DriftOperationConditionResult {
    case satisfied
    case failed(with: Error)
    
    var error: Error? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: Evaluate Conditions

extension Collection where Iterator.Element == DriftOperationCondition, IndexDistance == Int {
    func evaluate(forOperation operation: DriftOperation, completion: ([Error]) -> Void) {
        // Check conditions.
        let conditionGroup = DispatchGroup()
        var results = [DriftOperationConditionResult?](repeating: nil, count: self.count)

        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in self.enumerated() {
            conditionGroup.enter()
            condition.evaluateForOperation(operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        conditionGroup.notify(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default)) {
            // Aggregate the errors that occurred, in order.
            let failures = results.flatMap({ $0?.error })
            completion(failures)
        }
    }
}

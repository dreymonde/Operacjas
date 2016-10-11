/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the fundamental logic relating to Operacja conditions.
*/

import Foundation

public let OperacjaConditionKey = "OperacjaCondition"

/**
    A protocol for defining conditions that must be satisfied in order for an
    operation to begin execution.
*/
public protocol OperacjaCondition {
    
    /// The name of the condition
    static var name: String { get }
        
    /**
        Some conditions may have the ability to satisfy the condition if another
        operation is executed first. Use this method to return an operation that
        (for example) asks for permission to perform the operation
        
        - parameter operation: The `Operacja` to which the Condition has been added.
        - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
        - note: Only a single operation may be returned as a dependency. If you
            find that you need to return multiple operations, then you should be
            expressing that as multiple conditions. Alternatively, you could return
            a single `GroupOperacja` that executes multiple operations internally.
    */
    func dependencyForOperation(operation: Operacja) -> NSOperation?
    
    /// Evaluate the condition, to see if it has been satisfied or not.
    func evaluateForOperation(operation: Operacja, completion: OperacjaConditionResult -> Void)
}

extension OperacjaCondition {
    public static var name: String {
        return String(Self)
    }
}

/**
    An enum to indicate whether an `OperacjaCondition` was satisfied, or if it
    failed with an error.
*/
public enum OperacjaConditionResult {
    case Satisfied
    case Failed(with: ErrorType)
    
    var error: ErrorType? {
        if case .Failed(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: Evaluate Conditions

extension CollectionType where Generator.Element == OperacjaCondition, Index.Distance == Int {
    func evaluate(forOperation operation: Operacja, completion: ([ErrorType]) -> Void) {
        // Check conditions.
        let conditionGroup = dispatch_group_create()
        var results = [OperacjaConditionResult?](count: self.count, repeatedValue: nil)

        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in self.enumerate() {
            dispatch_group_enter(conditionGroup)
            condition.evaluateForOperation(operation) { result in
                results[index] = result
                dispatch_group_leave(conditionGroup)
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            // Aggregate the errors that occurred, in order.
            let failures = results.flatMap({ $0?.error })
            completion(failures)
        }
    }
}

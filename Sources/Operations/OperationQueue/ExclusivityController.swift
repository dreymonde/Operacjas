/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file contains the code to automatically set up dependencies between mutually exclusive operations.
*/

import Foundation

/**
    `ExclusivityController` is a singleton to keep track of all the in-flight
    `Operacja` instances that have declared themselves as requiring mutual exclusivity.
    We use a singleton because mutual exclusivity must be enforced across the entire
    app, regardless of the `OperacjaQueue` on which an `Operacja` was executed.
*/
open class ExclusivityController {
    open static let sharedExclusivityController = ExclusivityController()
    
    fileprivate let serialQueue = DispatchQueue(label: "Operacjas.ExclusivityController", attributes: [])
    fileprivate var operations: [String: [Operacja]] = [:]
    
    fileprivate init() {
        /*
            A private initializer effectively prevents any other part of the app
            from accidentally creating an instance.
        */
    }
    
    /// Registers an operation as being mutually exclusive
    open func addOperation(_ operation: Operacja, categories: [String]) {
        /*
            This needs to be a synchronous operation.
            If this were async, then we might not get around to adding dependencies
            until after the operation had already begun, which would be incorrect.
        */
        serialQueue.sync {
            for category in categories {
                self.noqueue_addOperation(operation, category: category)
            }
        }
    }
    
    /// Unregisters an operation from being mutually exclusive.
    open func removeOperation(_ operation: Operacja, categories: [String]) {
        serialQueue.async {
            for category in categories {
                self.noqueue_removeOperation(operation, category: category)
            }
        }
    }
    
    
    // MARK: Operacja Management
    
    fileprivate func noqueue_addOperation(_ operation: Operacja, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)

        operations[category] = operationsWithThisCategory
    }
    
    fileprivate func noqueue_removeOperation(_ operation: Operacja, category: String) {
        let matchingOperations = operations[category]

        if var operationsWithThisCategory = matchingOperations,
           let index = operationsWithThisCategory.index(of: operation) {

            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }
    
}

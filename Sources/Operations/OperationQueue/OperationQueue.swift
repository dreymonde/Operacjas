/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains an NSOperationQueue subclass.
*/

import Foundation

/**
    The delegate of an `OperationQueue` can respond to `Operation` lifecycle
    events by implementing these methods.

    In general, implementing `OperationQueueDelegate` is not necessary; you would
    want to use an `OperationObserver` instead. However, there are a couple of
    situations where using `OperationQueueDelegate` can lead to simpler code.
    For example, `GroupOperation` is the delegate of its own internal
    `OperationQueue` and uses it to manage dependencies.
*/
public protocol OperationQueueDelegate: class {
    func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation)
    func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [ErrorType])
}

extension OperationQueueDelegate {
    public func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [ErrorType]) { }
}

/// The block that is called when operation is enqueued.
public typealias OperationQueueEnqueuingModule = (operation: Operation, queue: OperationQueue) -> Void

/**
    `OperationQueue` is an `NSOperationQueue` subclass that implements a large
    number of "extra features" related to the `Operation` class:
    
    - Notifying a delegate of all operation completion
    - Extracting generated dependencies from operation conditions
    - Setting up dependencies to enforce mutual exclusivity
*/
public class OperationQueue: NSOperationQueue {
    public weak var delegate: OperationQueueDelegate?
    
    public override func addOperation(operation: NSOperation) {
        dependOnVitals(operation)
        if let operation = operation as? Operation {
            
            // Set up an observer to invoke the `OperationQueueDelegate` method.
            operation.observe {
                $0.didProduceAnotherOperation { [weak self] operation in
                    self?.addOperation(operation)
                }
                $0.didFinishWithErrors { [weak self] errors in
                    if let queue = self {
                        queue.delegate?.operationQueue(queue, operationDidFinish: operation, withErrors: errors)
                    }
                }
            }
            
            // Extract any dependencies needed by this operation.
            let dependencies = operation.conditions.flatMap { $0.dependencyForOperation(operation) }
                
            for dependency in dependencies {
                operation.addDependency(dependency)
                self.addOperation(dependency)
            }
            
            /*
                With condition dependencies added, we can now see if this needs
                dependencies to enforce mutual exclusivity.
            */
            let concurrencyCategories: [String] = operation.exclusivityCategories.map({ $0.categoryIdentifier })

            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedExclusivityController

                exclusivityController.addOperation(operation, categories: concurrencyCategories)
                
                operation.observe {
                    $0.didFinishWithErrors { _ in
                        exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                    }
                }
            }
            
            // Connecting all user-defined modules. That's a fine alternative to delegates.
            for module in modules {
                module(operation: operation, queue: self)
            }
            
            /*
                Indicate to the operation that we've finished our extra work on it
                and it's now it a state where it can proceed with evaluating conditions,
                if appropriate.
            */
            operation._willEnqueue()
        }
        else {
            /*
                For regular `NSOperation`s, we'll manually call out to the queue's
                delegate we don't want to just capture "operation" because that
                would lead to the operation strongly referencing itself and that's
                the pure definition of a memory leak.
            */
            operation.addCompletionBlock { [weak self, weak operation] in
                guard let queue = self, let operation = operation else { return }
                queue.delegate?.operationQueue(queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue(self, willAddOperation: operation)
        super.addOperation(operation)
    }
    
    public override func addOperations(operations: [NSOperation], waitUntilFinished wait: Bool) {
        /*
            The base implementation of this method does not call `addOperation()`,
            so we'll call it ourselves.
        */
        for operation in operations {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
              operation.waitUntilFinished()
            }
        }
    }
    
    private var modules: [OperationQueueEnqueuingModule] = []
    
    public func addEnqueuingModule(module: OperationQueueEnqueuingModule) {
        modules.append(module)
    }
    
    public func addOperation(operation: NSOperation, vital: Bool) {
        addDependency(operation)
        addOperation(operation)
    }
    
    private let vitalAccessQueue = dispatch_queue_create("com.AdvancedOperations.VitalOperationsAccessQueue", DISPATCH_QUEUE_SERIAL)
    private var vitalOperations: [NSOperation] = []
    
    private func dependOnVitals(operation: NSOperation) {
        dispatch_sync(vitalAccessQueue) {
            for vital in self.vitalOperations where vital !== operation {
                operation.addDependency(vital)
            }
        }
    }
    
    public func addDependency(operation: NSOperation) {
        dispatch_sync(vitalAccessQueue) {
            self.vitalOperations.append(operation)
        }
        operation.addCompletionBlock {
            dispatch_sync(self.vitalAccessQueue) {
                if let index = self.vitalOperations.indexOf(operation) {
                    self.vitalOperations.removeAtIndex(index)
                }
            }
        }
    }
    
}

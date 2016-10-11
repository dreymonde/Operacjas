/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how operations can be composed together to form new operations.
*/

import Foundation

/**
    A subclass of `Operacja` that executes zero or more operations as part of its
    own execution. This class of operation is very useful for abstracting several
    smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
    is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.

    Additionally, `GroupOperacja`s are useful if you establish a chain of dependencies,
    but part of the chain may "loop". For example, if you have an operation that
    requires the user to be authenticated, you may consider putting the "login"
    operation inside a group operation. That way, the "login" operation may produce
    subsequent operations (still within the outer `GroupOperacja`) that will all
    be executed before the rest of the operations in the initial chain of operations.
*/
open class GroupOperacja : Operacja {
    fileprivate let internalQueue = OperacjaQueue()
    fileprivate let startingOperation = BlockOperation(block: {})
    fileprivate let finishingOperation = BlockOperation(block: {})

    fileprivate var aggregatedErrors = [Error]()
    
    public init(operations: [Operation], configureQueue: ((OperacjaQueue) -> Void)? = nil) {
        super.init()
        
        configureQueue?(internalQueue)
        internalQueue.isSuspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)

        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    open override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    open override func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    open func addOperation(_ operation: Operation) {
        internalQueue.addOperation(operation)
    }
    
    /**
        Note that some part of execution has produced an error.
        Errors aggregated through this method will be included in the final array
        of errors reported to observers and to the `finished(_:)` method.
    */
    public final func aggregate(_ error: Error) {
        aggregatedErrors.append(error)
    }
    
    open func operationDidFinish(_ operation: Operation, with errors: [Error]) {
        // For use by subclassers.
    }
    
    /// This method is called right before GroupOperacja finishes it's execution. Do not try to add any more operations at this point.
    open func groupOperationWillFinish() {
        // For use by subclassers
    }
    
}

extension GroupOperacja : OperacjaQueueDelegate {
    public final func operationQueue(_ operationQueue: OperacjaQueue, willAdd operation: Operation) {
        assert(!finishingOperation.isFinished && !finishingOperation.isExecuting, "cannot add new operations to a group after the group has completed")
        
        /*
            Some operation in this group has produced a new operation to execute.
            We want to allow that operation to execute before the group completes,
            so we'll make the finishing operation dependent on this newly-produced operation.
        */
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        /*
            All operations should be dependent on the "startingOperation".
            This way, we can guarantee that the conditions for other operations
            will not evaluate until just before the operation is about to run.
            Otherwise, the conditions could be evaluated at any time, even
            before the internal operation queue is unsuspended.
        */
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    
    public final func operationQueue(_ operationQueue: OperacjaQueue, operationDidFinish operation: Operation, with errors: [Error]) {
        aggregatedErrors.append(contentsOf: errors)
        
        if operation === finishingOperation {
            internalQueue.isSuspended = true
            groupOperationWillFinish()
            finish(errors: aggregatedErrors)
        }
        else if operation !== startingOperation {
            operationDidFinish(operation, with: errors)
        }
    }
}

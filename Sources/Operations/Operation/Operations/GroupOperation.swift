/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how operations can be composed together to form new operations.
*/

import Foundation

/**
    A subclass of `DriftOperation` that executes zero or more operations as part of its
    own execution. This class of operation is very useful for abstracting several
    smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
    is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.

    Additionally, `GroupOperation`s are useful if you establish a chain of dependencies,
    but part of the chain may "loop". For example, if you have an operation that
    requires the user to be authenticated, you may consider putting the "login"
    operation inside a group operation. That way, the "login" operation may produce
    subsequent operations (still within the outer `GroupOperation`) that will all
    be executed before the rest of the operations in the initial chain of operations.
*/
public class GroupOperation: DriftOperation {
    private let internalQueue = DriftOperationQueue()
    private let startingOperation = NSBlockOperation(block: {})
    private let finishingOperation = NSBlockOperation(block: {})

    private var aggregatedErrors = [ErrorType]()
    
    public init(operations: [NSOperation], configureQueue: ((DriftOperationQueue) -> Void)? = nil) {
        super.init()
        
        configureQueue?(internalQueue)
        internalQueue.suspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)

        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    public override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    public override func execute() {
        internalQueue.suspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    public func addOperation(operation: NSOperation) {
        internalQueue.addOperation(operation)
    }
    
    /**
        Note that some part of execution has produced an error.
        Errors aggregated through this method will be included in the final array
        of errors reported to observers and to the `finished(_:)` method.
    */
    public final func aggregateError(error: ErrorType) {
        aggregatedErrors.append(error)
    }
    
    public func operationDidFinish(operation: NSOperation, withErrors errors: [ErrorType]) {
        // For use by subclassers.
    }
    
    /// This method is called right before GroupOperation finishes it's execution. Do not try to add any more operations at this point.
    public func groupOperationWillFinish() {
        // For use by subclassers
    }
    
}

extension GroupOperation: DriftOperationQueueDelegate {
    public final func operationQueue(operationQueue: DriftOperationQueue, willAddOperation operation: NSOperation) {
        assert(!finishingOperation.finished && !finishingOperation.executing, "cannot add new operations to a group after the group has completed")
        
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
    
    public final func operationQueue(operationQueue: DriftOperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [ErrorType]) {
        aggregatedErrors.appendContentsOf(errors)
        
        if operation === finishingOperation {
            internalQueue.suspended = true
            groupOperationWillFinish()
            finish(with: aggregatedErrors)
        }
        else if operation !== startingOperation {
            operationDidFinish(operation, withErrors: errors)
        }
    }
}

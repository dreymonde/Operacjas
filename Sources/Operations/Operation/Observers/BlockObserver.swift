/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the DriftOperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `DriftOperation`'s lifecycle. Deprecated.
 
    - Note: Use `BlockObserver` only as a reusable object. For individual observing, use `operation.observe` instead.
*/
@available(*, deprecated, message="Use 'operation.observe' for single operation observing, or implement 'DriftOperationObserver' if you want your observer to be reusable.")
public struct BlockObserver: DriftOperationObserver {
    // MARK: Properties
    
    private let startHandler: (DriftOperation -> Void)?
    private let produceHandler: ((DriftOperation, NSOperation) -> Void)?
    private let finishHandler: ((DriftOperation, [ErrorType]) -> Void)?
    
    public init(startHandler: (DriftOperation -> Void)? = nil, produceHandler: ((DriftOperation, NSOperation) -> Void)? = nil, finishHandler: ((DriftOperation, [ErrorType]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: DriftOperationObserver
    
    public func operationDidStart(operation: DriftOperation) {
        startHandler?(operation)
    }
    
    public func operation(operation: DriftOperation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: DriftOperation, errors: [ErrorType]) {
        finishHandler?(operation, errors)
    }
}

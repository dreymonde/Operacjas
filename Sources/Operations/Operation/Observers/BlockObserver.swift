/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperacjaObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operacja`'s lifecycle. Deprecated.
 
    - Note: Use `BlockObserver` only as a reusable object. For individual observing, use `operation.observe` instead.
*/
@available(*, deprecated, message="Use 'operation.observe' for single operation observing, or implement 'OperacjaObserver' if you want your observer to be reusable.")
public struct BlockObserver: OperacjaObserver {
    // MARK: Properties
    
    private let startHandler: (Operacja -> Void)?
    private let produceHandler: ((Operacja, NSOperation) -> Void)?
    private let finishHandler: ((Operacja, [ErrorType]) -> Void)?
    
    public init(startHandler: (Operacja -> Void)? = nil, produceHandler: ((Operacja, NSOperation) -> Void)? = nil, finishHandler: ((Operacja, [ErrorType]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperacjaObserver
    
    public func operationDidStart(operation: Operacja) {
        startHandler?(operation)
    }
    
    public func operation(operation: Operacja, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: Operacja, errors: [ErrorType]) {
        finishHandler?(operation, errors)
    }
}

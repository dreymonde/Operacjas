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
@available(*, deprecated, message: "Use 'operation.observe' for single operation observing, or implement 'OperacjaObserver' if you want your observer to be reusable.")
public struct BlockObserver: OperacjaObserver {
    // MARK: Properties
    
    fileprivate let startHandler: ((Operacja) -> Void)?
    fileprivate let produceHandler: ((Operacja, Operation) -> Void)?
    fileprivate let finishHandler: ((Operacja, [Error]) -> Void)?
    
    public init(startHandler: ((Operacja) -> Void)? = nil, produceHandler: ((Operacja, Operation) -> Void)? = nil, finishHandler: ((Operacja, [Error]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperacjaObserver
    
    public func operationDidStart(_ operation: Operacja) {
        startHandler?(operation)
    }
    
    public func operation(_ operation: Operacja, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(_ operation: Operacja, errors: [Error]) {
        finishHandler?(operation, errors)
    }
}

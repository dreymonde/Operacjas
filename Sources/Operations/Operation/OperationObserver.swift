/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the OperacjaObserver protocol.
*/

import Foundation

/**
    The protocol that types may implement if they wish to be notified of significant
    operation lifecycle events.
*/
public protocol OperacjaObserver {
    
    /// Invoked immediately prior to the `Operacja`'s `execute()` method.
    func operationDidStart(operation: Operacja)
    
    /// Invoked when `Operacja.produceOperation(_:)` is executed.
    func operation(operation: Operacja, didProduceOperation newOperation: NSOperation)
    
    /**
        Invoked as an `Operacja` finishes, along with any errors produced during
        execution (or readiness evaluation).
    */
    func operationDidFinish(operation: Operacja, errors: [ErrorType])
    
}

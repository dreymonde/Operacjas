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
    func operationDidStart(_ operation: Operacja)
    
    /// Invoked when `Operacja.produceOperation(_:)` is executed.
    func operation(_ operation: Operacja, didProduceOperation newOperation: Operation)
    
    /**
        Invoked as an `Operacja` finishes, along with any errors produced during
        execution (or readiness evaluation).
    */
    func operationDidFinish(_ operation: Operacja, errors: [Error])
    
}

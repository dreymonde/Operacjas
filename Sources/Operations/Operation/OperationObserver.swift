/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the DriftOperationObserver protocol.
*/

import Foundation

/**
    The protocol that types may implement if they wish to be notified of significant
    operation lifecycle events.
*/
public protocol DriftOperationObserver {
    
    /// Invoked immediately prior to the `DriftOperation`'s `execute()` method.
    func operationDidStart(_ operation: DriftOperation)
    
    /// Invoked when `DriftOperation.produceOperation(_:)` is executed.
    func operation(_ operation: DriftOperation, didProduceOperation newOperation: Foundation.Operation)
    
    /**
        Invoked as an `DriftOperation` finishes, along with any errors produced during
        execution (or readiness evaluation).
    */
    func operationDidFinish(_ operation: DriftOperation, errors: [Error])
    
}

@available(*, unavailable, renamed: "DriftOperationObserver")
public typealias OperationObserver = DriftOperationObserver

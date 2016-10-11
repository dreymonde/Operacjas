//
//  ObserverBuilder.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 14.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public struct BuilderObserver: OperacjaObserver {
    
    private var start: (() -> ())?
    private var produce: ((NSOperation) -> ())?
    private var finish: (([ErrorType]) -> ())?
    private var success: (() -> ())?
    private var error: (([ErrorType]) -> ())?
    
    public mutating func didStart(handler: () -> ()) {
        self.start = handler
    }
    
    public mutating func didProduceAnotherOperation(handler: (produced: NSOperation) -> ()) {
        self.produce = handler
    }
    
    // WARNING! Usage of this method will ignore didSuccess and didFailed calls. Use them instead in most cases.
    public mutating func didFinishWithErrors(handler: (errors: [ErrorType]) -> ()) {
        self.finish = handler
    }
    
    public mutating func didSuccess(handler: () -> ()) {
        self.success = handler
    }
    
    public mutating func didFail(handler: (errors: [ErrorType]) -> ()) {
        self.error = handler
    }
    
    public func operationDidStart(operation: Operacja) {
        self.start?()
    }
    
    public func operation(operation: Operacja, didProduceOperation newOperation: NSOperation) {
        self.produce?(newOperation)
    }
    
    public func operationDidFinish(operation: Operacja, errors: [ErrorType]) {
        if let finishHandler = finish {
            finishHandler(errors)
        } else {
            if errors.isEmpty {
                success?()
            } else {
                error?(errors)
            }
        }
    }
    
}

extension Operacja {
    
    public func observe(build: (inout operation: BuilderObserver) -> ()) {
        var builderObserver = BuilderObserver()
        build(operation: &builderObserver)
        self.addObserver(builderObserver)
    }
    
}

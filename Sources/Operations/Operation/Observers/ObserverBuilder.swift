//
//  ObserverBuilder.swift
//  Operations
//
//  Created by Oleg Dreyman on 14.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public final class ObserverBuilder {
    
    private var startHandler: ((Operation) -> Void)?
    private var produceHandler: ((Operation, NSOperation) -> Void)?
    private var finishHandler: ((Operation) -> Void)?
    private var errorHandler: (([ErrorType]) -> Void)?
    
}

extension ObserverBuilder {
    
    public func didStart(handler: (Operation -> Void)) {
        self.startHandler = handler
    }
    
    public func didProduceAnotherOperation(handler: ((Operation, NSOperation) -> Void)) {
        self.produceHandler = handler
    }
    
    public func didFinish(handler: ((Operation) -> Void)) {
        self.finishHandler = handler
    }
    
    public func didFailed(handler: (([ErrorType]) -> Void)) {
        self.errorHandler = handler
    }
        
}

private struct ObserverBuilderObserver: OperationObserver {
    
    let builder: ObserverBuilder
    
    init(builder: ObserverBuilder) {
        self.builder = builder
    }
    
    private func operationDidStart(operation: Operation) {
        builder.startHandler?(operation)
    }
    
    private func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        builder.produceHandler?(operation, newOperation)
    }
    
    private func operationDidFinish(operation: Operation, errors: [ErrorType]) {
        if !errors.isEmpty {
            builder.errorHandler?(errors)
        }
        builder.finishHandler?(operation)
    }
}

extension Operation {
    
    public func observe(build: (ObserverBuilder) -> Void) {
        let builder = ObserverBuilder()
        build(builder)
        let observer = ObserverBuilderObserver(builder: builder)
        self.addObserver(observer)
    }
    
}

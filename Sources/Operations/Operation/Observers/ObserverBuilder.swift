//
//  ObserverBuilder.swift
//  Operations
//
//  Created by Oleg Dreyman on 14.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public final class ObserverBuilder {
    
    private var startHandler: ((Void) -> Void)?
    private var produceHandler: ((NSOperation) -> Void)?
    private var finishHandler: (([ErrorType]) -> Void)?
    private var successHandler: ((Void) -> Void)?
    private var errorHandler: (([ErrorType]) -> Void)?
    
}

extension ObserverBuilder {
    
    public func didStart(handler: ((Void) -> Void)) {
        self.startHandler = handler
    }
    
    public func didProduceAnotherOperation(handler: ((NSOperation) -> Void)) {
        self.produceHandler = handler
    }
    
    // WARNING! Usage of this method will ignore didSuccess and didFailed calls. Use them instead in most cases.
    public func didFinishWithErrors(handler: (([ErrorType]) -> Void)) {
        self.finishHandler = handler
    }
    
    public func didSuccess(handler: (Void) -> Void) {
        self.successHandler = handler
    }
    
    public func didFail(handler: (([ErrorType]) -> Void)) {
        self.errorHandler = handler
    }
        
}

private struct ObserverBuilderObserver: OperationObserver {
    
    let builder: ObserverBuilder
    
    init(builder: ObserverBuilder) {
        self.builder = builder
    }
    
    private func operationDidStart(operation: Operation) {
        builder.startHandler?()
    }
    
    private func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        builder.produceHandler?(newOperation)
    }
    
    private func operationDidFinish(operation: Operation, errors: [ErrorType]) {
        if let finishHandler = builder.finishHandler {
            finishHandler(errors)
        } else {
            if errors.isEmpty {
                builder.successHandler?()
            } else {
                builder.errorHandler?(errors)
            }
        }
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

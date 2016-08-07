//
//  ObserverBuilder.swift
//  DriftOperations
//
//  Created by Oleg Dreyman on 14.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public final class ObserverBuilder {
    
    private var startHandler: ((Void) -> Void)?
    private var produceHandler: ((Operation) -> Void)?
    private var finishHandler: (([Error]) -> Void)?
    private var successHandler: ((Void) -> Void)?
    private var errorHandler: (([Error]) -> Void)?
    
}

extension ObserverBuilder {
    
    public func didStart(_ handler: () -> ()) {
        self.startHandler = handler
    }
    
    public func didProduceAnotherOperation(_ handler: (produced: Operation) -> ()) {
        self.produceHandler = handler
    }
    
    // WARNING! Usage of this method will ignore didSuccess and didFailed calls. Use them instead in most cases.
    public func didFinishWithErrors(_ handler: (errors: [Error]) -> ()) {
        self.finishHandler = handler
    }
    
    public func didSuccess(_ handler: () -> ()) {
        self.successHandler = handler
    }
    
    public func didFail(_ handler: (errors: [Error]) -> ()) {
        self.errorHandler = handler
    }
        
}

private struct ObserverBuilderObserver: DriftOperationObserver {
    
    let builder: ObserverBuilder
    
    init(builder: ObserverBuilder) {
        self.builder = builder
    }
    
    private func operationDidStart(_ operation: DriftOperation) {
        builder.startHandler?()
    }
    
    private func operation(_ operation: DriftOperation, didProduce newOperation: Operation) {
        builder.produceHandler?(newOperation)
    }
    
    private func operationDidFinish(_ operation: DriftOperation, with errors: [Error]) {
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

extension DriftOperation {
    
    public func observe(_ build: (operation: ObserverBuilder) -> ()) {
        let builder = ObserverBuilder()
        build(operation: builder)
        let observer = ObserverBuilderObserver(builder: builder)
        self.addObserver(observer)
    }
    
}

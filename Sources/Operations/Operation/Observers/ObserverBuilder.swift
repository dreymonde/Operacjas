//
//  ObserverBuilder.swift
//  Operacjas
//
//  Created by Oleg Dreyman on 14.05.16.
//  Copyright © 2016 AdvancedOperations. All rights reserved.
//

import Foundation

public struct BuilderObserver: OperacjaObserver {
    
    fileprivate var start: (() -> ())?
    fileprivate var produce: ((Operation) -> ())?
    fileprivate var finish: (([Error]) -> ())?
    fileprivate var success: (() -> ())?
    fileprivate var error: (([Error]) -> ())?
    
    public mutating func didStart(_ handler: @escaping () -> ()) {
        self.start = handler
    }
    
    public mutating func didProduceAnotherOperation(_ handler: @escaping (_ produced: Operation) -> ()) {
        self.produce = handler
    }
    
    // WARNING! Usage of this method will ignore didSuccess and didFailed calls. Use them instead in most cases.
    public mutating func didFinishWithErrors(_ handler: @escaping (_ errors: [Error]) -> ()) {
        self.finish = handler
    }
    
    public mutating func didSuccess(_ handler: @escaping () -> ()) {
        self.success = handler
    }
    
    public mutating func didFail(_ handler: @escaping (_ errors: [Error]) -> ()) {
        self.error = handler
    }
    
    public func operationDidStart(_ operation: Operacja) {
        self.start?()
    }
    
    public func operation(_ operation: Operacja, didProduceOperation newOperation: Operation) {
        self.produce?(newOperation)
    }
    
    public func operationDidFinish(_ operation: Operacja, errors: [Error]) {
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
    
    public func observe(_ build: (_ operation: inout BuilderObserver) -> ()) {
        var builderObserver = BuilderObserver()
        build(&builderObserver)
        self.addObserver(builderObserver)
    }
    
}
